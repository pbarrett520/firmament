local inspect = require('inspect')

-- ImGui extensions
imgui.extensions = imgui.extensions or {}
imgui.internal = imgui.internal or {}

local types = {
  'number',
  'string',
  'bool',
  'table'
}

imgui.extensions.Table = function(t)
  for member, value in pairs(t) do
	local value_type = type(value)
	
	if value_type == 'string' then
	  imgui.extensions.VariableName(member)
	  imgui.SameLine()
	  imgui.Text(value)
	elseif value_type == 'number' then
	  imgui.extensions.VariableName(member)
	  imgui.SameLine()
	  imgui.Text(tostring(value))
	elseif value_type == 'boolean' then
	  imgui.extensions.VariableName(member)
	  imgui.SameLine()
	  imgui.Text(tostring(value))
	elseif value_type == 'table' then
	  imgui.extensions.TableMenuItem(member, value)
	end
  end
end

imgui.extensions.TableMenuItem = function(name, t)
  local address = table_address(t)
  local imgui_id = name .. '##' .. address
  
  if imgui.TreeNode(imgui_id) then
	imgui.extensions.Table(t)
	imgui.TreePop()
  end
end

imgui.extensions.TableEditor = function(editing, params)
  if not params then params = {} end
  local editor = {
	is_table_editor = true,
    key_id = tdengine.uuid_imgui(),
    value_id = tdengine.uuid_imgui(),
    type_id = tdengine.uuid_imgui(),
	selected_type = 'string',
	editing = editing,
	children = {},
	imgui_ignore = params.imgui_ignore or {},
	array_replace_name = params.array_replace_name or nil,
	draw_field_add = params.draw_field_add or false,
	child_field_add = params.child_field_add or false,
	context_menu_item = nil,
	draw = function(self) imgui.internal.draw_table_editor(self) end,
	clear = function(self) imgui.internal.clear_table_editor(self) end
  }

  if editing == nil then dbg() end
  -- Each child member that is a non-recursive table also gets an editor
  for key, value in pairs(editing) do
	local recurse = type(value) == 'table'
	recurse = recurse and not (value == editing)
	recurse = recurse and not editing.is_table_editor
	if recurse then
	  local params = imgui.internal.propagate_table_editor_params(editor)	  
	  editor.children[key] = imgui.extensions.TableEditor(value, params)
	end
  end

  return editor
end

imgui.internal.draw_table_field_add = function(editor)
  imgui.PushItemWidth(80)
  if imgui.BeginCombo(editor.type_id, editor.selected_type) then
	for index, name in pairs(types) do
	  if imgui.Selectable(name) then
		editor.selected_type = name
	  end
	end
	imgui.EndCombo()
  end
  imgui.PopItemWidth()

  imgui.SameLine()
  imgui.extensions.VariableName('key')

  local enter_on_key = false
  local enter_on_value = false
  imgui.PushItemWidth(100)
  imgui.SameLine()
  enter_on_key = imgui.InputText(editor.key_id)
  imgui.PopItemWidth()

  imgui.PushItemWidth(170)
  if editor.selected_type ~= 'table' then
	imgui.SameLine()
	imgui.extensions.VariableName('value')
	
	imgui.SameLine()
	enter_on_value = imgui.InputText(editor.value_id)
  end

  if enter_on_key or enter_on_value then
	local key = imgui.InputTextContents(editor.key_id)
	imgui.InputTextSetContents(editor.key_id, '')
	key = tonumber(key) or key
	
	local value = imgui.InputTextContents(editor.value_id)
	imgui.InputTextSetContents(editor.value_id, '')
	
	if value == 'nil' then
	  value = nil
	elseif editor.selected_type == 'number' then
	  value = tonumber(value)
	elseif editor.selected_type == 'string' then
	  value = tostring(value)
	elseif editor.selected_type == 'bool' then
	  value = (value == 'true')
	elseif editor.selected_type == 'table' then
	  local params = imgui.internal.propagate_table_editor_params(editor)	  
	  editor.children[key] = imgui.extensions.TableEditor(value, params)
	end

	editor.editing[key] = value
	imgui.SetKeyboardFocusHere(-1)
  end
  imgui.PopItemWidth()

  return enter_on_key or enter_on_value
end

imgui.internal.table_editor_padding = function(editor)
-- Very hacky way to line up the inputs: Figure out the largest key, then when drawing a key,
  -- use the difference in length between current key and largest key as a padding. Does not work
  -- that well, but kind of works
  local padding_threshold = 12
  local padding_target = 0
  for key, value in pairs(editor.editing) do
	local key_len = 0
	if type(key) == 'string' then key_len = #key end
	if type(key) == 'number' then key_len = #tostring(key) end -- whatever
	if type(key) == 'boolean' then key_len = #tostring(key) end
	padding_target = math.max(padding_target, key_len)
  end

  local min_padding = 80
  local padding = math.max(padding_target * 10, min_padding)
  return padding
end

imgui.internal.draw_table_editor = function(editor)
  if editor.draw_field_add then imgui.internal.draw_table_field_add(editor) end

  local cursor = imgui.GetCursorPosX()
  local padding = imgui.internal.table_editor_padding(editor)
  local open_item_context_menu = false

  for key, value in pairs(editor.editing) do
	local display = not editor.imgui_ignore[key]
	local label = string.format('##%s', hash_table_entry(editor.editing, tostring(key)))

	local display_key = key
	if type(key) == 'number' and editor.array_replace_name then
	  display_key = editor.array_replace_name(key, value)
	end
	
	-- This is a two-way binding. If ImGui says that the input box was edited, we take the value from C and put it into Lua.
	-- Otherwise, we take the value from Lua and put it into C, in case any value changes in the interpreter. This is slow -- it
	-- means we copy every string in all tables we're editing into C every frame. I can't think of a better way to do it, because
	-- there is no mechanism for triggering a callback whenever a string in Lua changes (nor would we want one) short of
	-- metatable insanity.
	if display then 
	  if type(value) == 'string' then
		imgui.extensions.VariableName(display_key)
		if imgui.IsItemClicked(1) then open_item_context_menu = true; editor.context_menu_item = key end
		imgui.SameLine()
		imgui.SetCursorPosX(cursor + padding)
		imgui.PushItemWidth(-1)
		
		if imgui.InputText2(label) then
		  editor.editing[key] = imgui.InputTextGet(label)
		else
		  imgui.InputTextSet(label, editor.editing[key])
		end
		imgui.PopItemWidth()
	  elseif type(value) == 'number' then
		imgui.extensions.VariableName(display_key)
		if imgui.IsItemClicked(1) then open_item_context_menu = true; editor.context_menu_item = key end
		imgui.SameLine()
		imgui.SetCursorPosX(cursor + padding)
		imgui.PushItemWidth(-1)
		if imgui.InputFloat(label) then
		  editor.editing[key] = imgui.InputFloatGet(label)
		else
		  imgui.InputFloatSet(label, editor.editing[key])
		end
		imgui.PopItemWidth()
	  elseif type(value) == 'boolean' then
		imgui.extensions.VariableName(display_key)
		if imgui.IsItemClicked(1) then open_item_context_menu = true; editor.context_menu_item = key end
		imgui.SameLine()
		imgui.SetCursorPosX(cursor + padding)
		imgui.PushItemWidth(-1)
		
		if imgui.Checkbox(label) then
		  editor.editing[key] = imgui.CheckboxGet(label)
		else
		  imgui.CheckboxSet(label, editor.editing[key])
		end
	  elseif type(value) == 'table' then
		if not editor.children[key] then
		  local params = imgui.internal.propagate_table_editor_params(editor)
		  editor.children[key] = imgui.extensions.TableEditor(value, params)
		end
		local child = editor.children[key]

		-- Modals! If the table's tree node is clicked, we want to draw it. If it's right clicked,
		-- we want to open a popup where you can add new fields.
		local open_context_menu = false
		local unique_treenode_id = display_key .. label
		if imgui.TreeNode(unique_treenode_id) then
		  if imgui.IsItemClicked(1) then open_context_menu = true end
		  child:draw()
		  imgui.TreePop()
		end
		if imgui.IsItemClicked(1) then open_context_menu = true end

		-- Show the context menu
		local open_field_editor = false
		local context_menu_id = label .. ':context_menu'
		if open_context_menu then
		  imgui.OpenPopup(context_menu_id)
		end
		if imgui.BeginPopup(context_menu_id) then
		  if imgui.MenuItem('Add field') then
			open_field_editor = true
		  end
		  imgui.EndPopup()
		end

		-- Show the aforementioned field editor modal
		local field_editor_id = label .. ':field_editor'
		if open_field_editor then
		  imgui.OpenPopup(field_editor_id)
		end
		if imgui.BeginPopup(field_editor_id) then
		  if imgui.internal.draw_table_field_add(child) then
			imgui.CloseCurrentPopup()
		  end
		  imgui.EndPopup()
		end
	  end
	end
  end

  -- If any variable was right clicked, we show a little context menu where you can delete it
  local item_context_menu_id = '##' .. hash_table_entry(editor.editing, editor.context_menu_item)
  if open_item_context_menu then
	imgui.OpenPopup(item_context_menu_id)
  end
  if imgui.BeginPopup(item_context_menu_id) then
	print(editor.editing, item_context_menu_id)
	if imgui.Button('Delete') then
	  editor.editing[editor.context_menu_item] = nil
	  editor.context_menu_item = nil
	  imgui.CloseCurrentPopup()
	end
	imgui.EndPopup()
  end

end

imgui.internal.propagate_table_editor_params = function(editor)
  local params = {}
  params.draw_field_add = editor.child_field_add
  return params
end

imgui.internal.clear_table_editor = function(editor)
  editor.key_id = tdengine.uuid_imgui()
  editor.value_id = tdengine.uuid_imgui()
  editor.type_id = tdengine.uuid_imgui()
  editor.children = {}
end

imgui.extensions.PushBoolColor = function()
  imgui.PushStyleColor_2(imgui.constant.Col.Text, .9, .2, .7, 1)
end

imgui.extensions.PushStringColor = function()
  imgui.PushStyleColor_2(imgui.constant.Col.Text, .5, .2, .7, 1)
end

imgui.extensions.PushNumberColor = function()
  imgui.PushStyleColor_2(imgui.constant.Col.Text, .1, .2, .7, 1)
end

imgui.extensions.InputFloat = function(label, value, format)
   local step = 0
   local step_fast = 0
   local format = format or "%3.f"
   local extra_flags = 0
   return imgui.InputFloat(label, value, step, step_fast, format, extra_flags)
end

imgui.extensions.VariableName = function(name)
   local color = tdengine.color32(0, 200, 200, 255)
   imgui.PushStyleColor(imgui.constant.Col.Text, color)
   imgui.Text(tostring(name))
   imgui.PopStyleColor()
   if imgui.IsItemHovered() then
	 sx, sy = imgui.GetItemRectSize();
	 x, y = imgui.GetItemRectMin();
	 px, py = 5, 3
	 local color = imgui.ColorConvertFloat4ToU32(0, 1, 0, .3)
	 imgui.AddRectFilled(x - px, y - py, x + sx + px, y + sy + py, color)
   end

end

imgui.extensions.RightAlignedString = function(str)
   local width = imgui.GetWindowWidth()
   local text_size = imgui.CalcTextSize(str)
   local padding = 10
   imgui.SameLine(width - text_size - padding)
   imgui.Text(str)
end

imgui.extensions.Vec2 = function(name, v)
   if not name or not v then
  print(v)
	  print('vec2 missing a parameter')
	  return
   end
   imgui.Text(name .. ': (' .. tostring(v.x) .. ', ' .. tostring(v.y) .. ')')
end

imgui.extensions.WhitespaceSeparator = function(whitespace)
  imgui.Dummy(0, whitespace)
  imgui.Separator()
  imgui.Dummy(0, whitespace)
end
