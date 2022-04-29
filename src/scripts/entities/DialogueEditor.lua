local glfw = require('glfw')
local inspect = require('inspect')

local DialogueEditor = tdengine.entity('DialogueEditor')
function DialogueEditor:init(params)  
  self.nodes = {}
  self.layout_data = {}
  self.loaded = ''
  self.selected = nil
  self.connecting = nil
  self.disconnecting = nil
  self.deleting = nil
  self.scrolling = tdengine.vec2(0, 0)
  self.scroll_per_second = 100
  self.window_position = tdengine.vec2(0, 0)
  self.input_id = '##ded_editor'
  self.text_who_id = '##ded:detail:set_entity'
  self.set_var_id = '##ded:detail:set_var'
  self.set_val_id = '##ded:detail:set_val'
  self.internal_id_id = '##ded:detail:set_internal_id'
  self.return_to_id = '##ded:detail:set_return_to'
  self.branch_on_id = '##ded:detail:set_branch_var'
  self.next_dialogue_id = '##ded:detail:next_dialogue'
  self.branch_val_id = '##ded:detail:set_branch_val'
  self.empty_name_id = '##ded:detail:set_empty_name'
  self.selected_editor = nil
  self.effect_editor = nil
  self.selected_effect = 1

  self.choosing_file = false
  
  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.Editor)
  self.input:enable()
  
  tdengine.create_entity('TextEditor')
end

function DialogueEditor:update(dt)  
  imgui.Begin('dialogue', true)

  -- Draw the sidebar
  imgui.BeginChild('sidebar', 400, 0)
  
  imgui.Text(self:full_path())
  
  -- Selected node detail view
  local selected = self.selected and self.nodes[self.selected]
  if selected then
	self.selected_editor:draw()

	if selected.kind == 'Text' or selected.kind == 'Choice' then
	  imgui.Dummy(0, 10)
	  imgui.Separator()
	  imgui.Dummy(0, 10)
	  
	  imgui.PushItemWidth(250)
	  if imgui.BeginCombo('##combo', tdengine.effect_names[self.selected_effect]) then
		for i, effect_type in pairs(tdengine.effect_names) do
		  local selected = i == self.selected_effect
		  if imgui.Selectable(effect_type, selected) then
			self.selected_effect = i
		  end

		  if selected then imgui.SetItemDefaultFocus() end
		end
		imgui.EndCombo()
	  end
	  imgui.PopItemWidth()

	  imgui.SameLine()
	  if imgui.Button('Add Effect') then
		table.insert(selected.effects, { type = self.selected_effect })
	  end

	  if imgui.TreeNode('effects') then
		self.effect_editor:draw()
		imgui.TreePop()
	  end
	end
  end

  
  -- bind selected node's text to what's in the editor
  if selected then
	if selected.kind == 'Text' or selected.kind == 'Choice' then
	  local text_editor = tdengine.find_entity('TextEditor')
	  selected.text = text_editor.text
	end
  end
  
  imgui.Dummy(0, 10)
  imgui.Separator()
  imgui.Dummy(0, 10)

  -- A list of all nodes, just using their short names
  local node_hovered_in_list = nil
	for id, node in pairs(self.nodes) do
	  local imid = id .. 'list_view'
	  imgui.PushID(imid)

	  -- Write the selected node in a different color
	  local pushed_color = false
	  if self.selected == id then
		local hl_color = tdengine.color32(0, 255, 0, 255)
		imgui.PushStyleColor(imgui.constant.Col.Text, hl_color)
		pushed_color = true
	  end

	  -- Display the node, and if clicked select it
	  if imgui.MenuItem(self:short_text(node)) then
		self:select(id, node)
	  end

	  -- Pop the color we pushed for the selected node!
	  if pushed_color then
		imgui.PopStyleColor()
	  end
	  
	  if imgui.IsItemHovered() then
		node_hovered_in_list = node.uuid
	  end

	  imgui.PopID()
	end
  
  imgui.Separator()
    
  imgui.EndChild() -- Sidebar

  imgui.SameLine()

  -- Canvas!
  imgui.BeginGroup()
  
  -- Set up the canvas
  imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 1, 1)
  imgui.PushStyleVar_2(imgui.constant.StyleVar.WindowPadding, 0, 0)

  local bg_color = tdengine.color32(60, 60, 70, 200)
  imgui.PushStyleColor(imgui.constant.Col.ChildBg, bg_color)
  
  local flags = bitwise(tdengine.op_or, imgui.constant.WindowFlags.NoScrollbar, imgui.constant.WindowFlags.NoMove)
  
  imgui.BeginChild('scrolling_region', 0, 0, true, flags)
  self.window_position = tdengine.vec2(imgui.GetCursorScreenPos())

  -- Draw the grid
  local cursor_x, cursor_y = imgui.GetCursorScreenPos()
  local offset = tdengine.vec2(
	self.scrolling.x + cursor_x,
	self.scrolling.y + cursor_y)
  local line_color = tdengine.color32(200, 200, 200, 40)
  local grid_size = 64
  local wsx, wsy = imgui.GetWindowSize()

  for off_x = math.fmod(self.scrolling.x, grid_size), wsx, grid_size do
	local top = tdengine.vec2(off_x, 0)
	top = self:canvas_screen_to_window_screen(top)
	
	local bottom = tdengine.vec2(off_x, wsy)
	bottom = self:canvas_screen_to_window_screen(bottom)
	
	imgui.DrawList_AddLine(top.x, top.y, bottom.x, bottom.y, line_color)
  end

  for off_y = math.fmod(self.scrolling.y, grid_size), wsy, grid_size do
	-- 
	local left = tdengine.vec2(0, off_y)
	left = self:canvas_screen_to_window_screen(left)
	
	local right = tdengine.vec2(wsx, off_y)
	right = self:canvas_screen_to_window_screen(right)

	imgui.DrawList_AddLine(left.x, left.y, right.x, right.y, line_color)
  end

  -- Draw nodes
  self.hovered = nil
  local node_padding = tdengine.vec2(8, 8)
  
  imgui.DrawList_ChannelsSplit(3)

  for id, node in pairs(self.nodes) do
	imgui.PushID(id)

	-- GUI data stored separately from actual game data
	local gnode = self.layout_data[id]
	local canvas_position = tdengine.vec2(gnode.position.x, gnode.position.y)

	local node_rect_min = self:canvas_world_to_window_screen(canvas_position)
	local node_contents_cursor = node_rect_min:add(node_padding)
	
	-- Draw the node contents
	imgui.DrawList_ChannelsSetCurrent(2)

	local old_any_active = imgui.IsAnyItemActive()

	imgui.SetCursorScreenPos(node_contents_cursor:unpack())

	-- Add any custom GUI items for each node kind
	imgui.BeginGroup()
	imgui.Text(node.kind)
	imgui.Text(self:short_text(node))
	imgui.EndGroup()

	local contents_size = tdengine.vec2(imgui.GetItemRectSize())
	local padding_size = node_padding:scale(2)
	gnode.size = contents_size:add(padding_size)
	local node_rect_max = node_rect_min:add(gnode.size)
	
	-- Set up the 'button' that makes up the node
	imgui.SetCursorScreenPos(node_rect_min:unpack())
	imgui.InvisibleButton('node', gnode.size:unpack())

	-- Figure out whether we're pressed, hovered, or dragged
	local pressed = imgui.IsItemActive()
	if pressed then
	  self:select(id, node)

	  -- If someone left clicked us, check whether they're trying to
	  -- (dis)connect themselves to you
	  if imgui.IsMouseClicked(0) then
		if self.connecting then
		  local parent = self.nodes[self.connecting]
		  table.insert(parent.children, id)
		  self.connecting = nil
		end
		if self.disconnecting then
		  local parent = self.nodes[self.disconnecting]
		  delete(parent.children, id)
		  self.disconnecting = nil
		end
	  end
	  
	  -- Pressed with left click? Drag
	  if imgui.IsMouseDragging(0) then
		local delta = tdengine.vec2(imgui.MouseDelta())
		local last_position = tdengine.vec2(gnode.position.x, gnode.position.y)
		gnode.position = last_position:add(delta)
	  end
	end

	-- Pressed with right click? Context menu
	if imgui.IsItemClicked(1) then
	  imgui.OpenPopup('node_context_menu')
	end

	imgui.PushStyleVar_2(imgui.constant.StyleVar.WindowPadding, 8, 8)
	if imgui.BeginPopup('node_context_menu') then
	  if imgui.MenuItem('Connect') then
		self.connecting = id
	  end
	  if imgui.MenuItem('Disconnect') then
		self.disconnecting = id
	  end
	  if imgui.MenuItem('Set as entry point') then
		for i, node in pairs(self.nodes) do
		  node.is_entry_point = false
		end

		node.is_entry_point = true
	  end

	  if imgui.MenuItem('Delete') then
		self.deleting = id
	  end
	  imgui.EndPopup()
	end
	imgui.PopStyleVar()

	local hovered = false
	if imgui.IsItemHovered() then
	  hovered = true
	end
	hovered = hovered or node_hovered_in_list == id
	
	if hovered then
	  self.hovered = id
	end

	-- Draw node background and slots
	imgui.DrawList_ChannelsSetCurrent(1)

	
	-- Slots
	local radius = 8
	local ay = average(node_rect_max.y, node_rect_min.y)

	local in_slot_color = tdengine.color32(255, 100, 255, 255)
	local in_slot = self:input_slot(id)
	imgui.DrawList_AddCircleFilled(in_slot.x, in_slot.y, radius, in_slot_color)

	local out_slot_color = tdengine.color32(100, 0, 200, 255)
	local out_slot = self:output_slot(id)
	imgui.DrawList_AddCircleFilled(out_slot.x, out_slot.y, radius, out_slot_color)
	
	-- Draw a rectangle for the node's background
	local hl_node_color = tdengine.color32(75, 75, 75, 255)
	local node_color = tdengine.color32(60, 60, 60, 255)
	
	local highlight = hovered or node.uuid == self.selected
	local color = ternary(highlight, hl_node_color, node_color)
	local rounding = 4
	imgui.DrawList_AddRectFilled(node_rect_min.x, node_rect_min.y, node_rect_max.x, node_rect_max.y, color, rounding)

	imgui.PopID() -- Unique node ID
  end

  -- Draw the links between nodes
  imgui.DrawList_ChannelsSetCurrent(0)

  local link_color = tdengine.color32(200, 200, 200, 255)
  local backlink_color = tdengine.color32(200, 100, 100, 255)
  local disconnect_color = tdengine.color32(255, 0, 0, 255)
  local thickness = 2

  for id, node in pairs(self.nodes) do
	local output_slot = self:output_slot(id)
	local use_dc_prompt_color = self.disconnecting == id
	
	local children = node.children
	for index, child_id in pairs(children) do
	  local input_slot = self:input_slot(child_id)

	  use_dc_prompt_color = use_dc_prompt_color and self.hovered == child_id

	  -- The graph looks super messy if we hook nodes later in the graph
	  -- to earlier nodes. So, instead of drawing the normal link, do a big
	  -- curve that swings around the whole graph (use the average of the two
	  -- slots' X coordinates for the peak)
	  if input_slot.x < output_slot.x then
		 local color = ternary(use_dc_prompt_color, disconnect_color, backlink_color)
		 local average = output_slot:subtract(input_slot):scale(.5)
		 imgui.DrawList_AddBezierCurve(
			output_slot.x, output_slot.y,
			output_slot.x - average.x, output_slot.y - 500,
			input_slot.x, input_slot.y,
			input_slot.x, input_slot.y,
			color, thickness)
	  else
		local color = ternary(use_dc_prompt_color, disconnect_color, link_color)
		local cp = tdengine.vec2(50, 0)
		imgui.DrawList_AddBezierCurve(
		  output_slot.x, output_slot.y,
		  output_slot.x + cp.x, output_slot.y,
		  input_slot.x - cp.x, input_slot.y,
		  input_slot.x, input_slot.y,
		  color, thickness)
	  end

	  -- To keep track of which branch node you will branch to depending on true / false /
	  -- index returned by branch function, label them.
	  if node.kind == 'Branch' then
		local middle = output_slot:add(input_slot):scale(.5)
		local colors = {
		  default = tdengine.color32(0, 255, 128, 255),
		  t = tdengine.color32(0, 255, 128, 255),
		  f = tdengine.color32(255, 0, 128, 255)
		}

		-- If there's more than two choices, we want to give it a number matching its index
		if #children > 2 then
		  -- Where the top left of the index glyph goes for >2 choices
		  local index_glyph_offset = tdengine.vec2(10, 15)
		  local index_glyph = middle:subtract(index_glyph_offset)

		  imgui.SetWindowFontScale(1.5)
		  imgui.SetCursorScreenPos(index_glyph:unpack())
		  imgui.PushStyleColor(imgui.constant.Col.Text, colors.default)
		  imgui.Text(tostring(index))
		  imgui.PopStyleColor()
		  imgui.SetWindowFontScale(1)
		-- If there are only two choices, label them with T/F dots
		elseif #children == 2 then		
		  local extents = tdengine.vec2(5, 5)
		  local min = middle:subtract(extents)
		  local max = middle:add(extents)
		  local color = ternary(index == 1, colors.t, colors.f)
		  local rounding = 50
		  imgui.DrawList_AddRectFilled(min.x, min.y, max.x, max.y, color, rounding)
		end
	  end
	end
  end

  if self.connecting then
	local p0 = self:output_slot(self.connecting)
	local cursor = tdengine.vec2(imgui.GetMousePos())

	imgui.DrawList_AddBezierCurve(
	  p0.x, p0.y,
	  p0.x + 50, p0.y + 50,
	  cursor.x - 50, cursor.y - 50,
	  cursor.x, cursor.y,
	  link_color, thickness)
  end

  imgui.DrawList_ChannelsMerge()

  if self.deleting then
	for id, node in pairs(self.nodes) do
	  delete(node.children, self.deleting)
	end

	if self.selected == self.deleting then self:select(nil) end
	if self.connecting == self.deleting then self.connecting = nil end
	if self.disconnecting == self.deleting then self.disconnecting = nil end

	self.nodes[self.deleting] = nil
	self.deleting = nil
  end
  

  -- Right clicking in window background brings up a menu.
  local rclick = imgui.IsMouseClicked(1)
  local in_window = imgui.IsMouseHoveringWindow()
  local on_node = imgui.IsAnyItemHovered()
  if rclick and in_window and not on_node then
	imgui.OpenPopup('context_menu')
  end

  imgui.PushStyleVar_2(imgui.constant.StyleVar.WindowPadding, 8, 8)
  if imgui.BeginPopup('context_menu') then
	if imgui.TreeNode('Add Node') then
	  local node = nil
	  for i, kind in pairs(tdengine.node_kinds) do
		if imgui.MenuItem(kind) then
		  node = self:make_dialogue_node(kind)
		end
	  end

	  if node then
		self.nodes[node.uuid] = node

		local mouse = tdengine.vec2(imgui.GetMousePos())
		self.layout_data[node.uuid] = {
		  position = mouse:subtract(self.window_position):subtract(self.scrolling),
		  size = tdengine.vec2(0, 0)
		}
	  end

	  imgui.TreePop()
	end
	imgui.EndPopup()
  end
  imgui.PopStyleVar()

  local canvas_hovered = imgui.IsWindowHovered()
  local middle_click = imgui.IsMouseDragging(2, 0)
  local clicked_on_node = imgui.IsAnyItemActive()

  if canvas_hovered and not clicked_on_node then
	 if middle_click then
		local delta = tdengine.vec2(imgui.MouseDelta())
		self.scrolling = self.scrolling:add(delta)
	 end

	 self.input:set_channel(tdengine.InputChannel.ImGui)

	 self.scroll_per_second = 1000
	 local delta = tdengine.vec2(0, 0)
 	 if self.input:is_down(glfw.keys.W) then
		delta.y = delta.y + (self.scroll_per_second * dt)
	 end
 	 if self.input:is_down(glfw.keys.S) then
		delta.y = delta.y - (self.scroll_per_second * dt)
	 end
 	 if self.input:is_down(glfw.keys.A) then
		delta.x = delta.x + (self.scroll_per_second * dt)
	 end
 	 if self.input:is_down(glfw.keys.D) then
		delta.x = delta.x - (self.scroll_per_second * dt)
	 end
	 
	 self.input:set_channel(tdengine.InputChannel.Editor)

	 self.scrolling = self.scrolling:add(delta)
  end

  imgui.EndChild()
  
  imgui.PopStyleVar()   -- FramePadding
  imgui.PopStyleVar()   -- WindowPadding
  imgui.PopStyleColor() -- ChildBg
  imgui.EndGroup()      -- Canvas

  imgui.End()
end

function DialogueEditor:make_dialogue_node(kind)
  local node = {
	kind = kind,
	is_entry_point = false,
	children = {},
	uuid = tdengine.uuid()
  }
  
  if kind == 'Text' then
	node.text = ''
	node.who = 'unknown'
	node.effects = {}
  elseif kind == 'Choice' then
	node.text = ''
  elseif kind == 'Set' then
	node.variable = 'buns'
	node.value = true
  elseif kind == 'Empty' then
	node.internal_name = 'Empty'
  elseif kind == 'Branch' then
	node.branch_on = 'put a variable to check'
  elseif kind == 'If' then
	node.branch_on = 'put a variable to check'
  elseif kind == 'Switch' then
	node.next_dialogue = 'empty_switch'
  elseif kind == 'ChoiceRepeat' then
	node.internal_id = 'Set this to an ID you can refer to from a Return node'
  elseif kind == 'Return' then
	node.return_to = 'Set this to an ID you used for the internal_id of another node. Autogenerated UUID also works.'
  end
  
  return node

end

function DialogueEditor:run() 
  tdengine.layout('ded-half')
  local controller = tdengine.find_entity('DialogueController')
  if controller then
	tdengine.destroy_entity(controller.id)
  end
	
  if self.loaded then
	local eid = tdengine.create_entity('DialogueController')
	local controller = tdengine.find_entity('DialogueController')
	controller:begin(self.loaded)
	
	tdengine.clear_mtb()
	tdengine.clear_choices()
  end
end

function DialogueEditor:load(name_or_path)
  local name = tdengine.extract_filename(name_or_path)
  name = tdengine.strip_extension(name)
  local path = tdengine.paths.dialogue(name)

  if #name == 0 then return end
  self.loaded = name
  self.selected = nil
  self.connecting = nil
  self.disconnecting = nil
  self.deleting = nil
  self.scrolling = tdengine.vec2(0, 0)
  imgui.InputTextSetContents(self.input_id, '')

  self.nodes = tdengine.load_dialogue(name)
  if not self.nodes then
	self.nodes = {}
	return
  end
  
  -- Load the GUI data
  self.layout_data = dofile(tdengine.paths.dialogue_layout(name))
  if not self.layout_data then
	self.nodes = {}
	self.self.layout_data = {}
	
	tdengine.log('no gui layout for dialogue, path = ' .. layout_path)
	return
  end
end

function DialogueEditor:save(name_or_path)
  local name = tdengine.extract_filename(name_or_path)
  name = tdengine.strip_extension(name)
  print(name)
  
  if #name == 0 then return end
  local serpent = require('serpent')

  -- Save out the engine data
  local data_path = tdengine.paths.dialogue(name)
  local data_file = io.open(data_path, 'w')
  if data_file then
	data_file:write('return ')
	data_file:write(serpent.block(self.nodes, { comment = false }))
	data_file:close()
  else
	print('ded_save(): could not open data file: ' .. data_path)
  end

  -- Save out the layout data
  local layout_path = tdengine.paths.dialogue_layout(name)
  local layout_file = io.open(layout_path, 'w')
  if layout_file then
	layout_file:write('return ')
	layout_file:write(serpent.block(self.layout_data, { comment = false }))
	layout_file:close()
  else
	print('ded_save(): could not open gui node data: ' .. layout_path)		 
  end
end

function DialogueEditor:new(name)
  if not name then
	print('ded_new(): no name')
	return
  end
  if #name == 0 then
	print('ded_new(): empty name')
	return
  end

  self.nodes = {}
  self:save(name)
  self:load(name)
end

function DialogueEditor:short_text(node)
  local max_size = 16
  if node.kind == 'Text' or node.kind == 'Choice' then
	if string.len(node.text) < max_size then
	  return string.sub(node.text, 0, max_size)
	else
	  return string.sub(node.text, 0, max_size - 3) .. '...'
	end
  elseif node.kind == 'Set' then
	 return node.variable
  elseif node.kind == 'Empty' then
	 return node.internal_name
  elseif node.kind == 'Branch' then
	 return node.branch_on
  elseif node.kind == 'If' then
	return node.branch_on
  elseif node.kind == 'Switch' then
	 return node.next_dialogue
  elseif node.kind == 'ChoiceRepeat' then
	 return node.internal_id
  elseif node.kind == 'Return' then
	 return node.return_to
  else
	print('DialogueEditor:ded_short_text(): missing entry: ' .. node.kind)
  end
end

function DialogueEditor:full_path()
  if string.len(self.loaded) > 0 then
	return 'src/scripts/dialogue/' .. self.loaded .. '.lua'
  end

  return 'no file loaded'
end

function DialogueEditor:select(id, node)
  self.selected = id
  if not self.selected then
	self.selected_editor = nil
	return
  end

  self.selected_editor = imgui.extensions.TableEditor(self.nodes[id])

  if node.kind == 'Empty' then
	imgui.InputTextSetContents(self.empty_name_id, node.internal_name)
  end

  if node.kind == 'Text' then
	imgui.InputTextSetContents(self.text_who_id, node.who)
	self.selected_editor.imgui_ignore = {
	  text = true,
	  effects = true
	}
	local node = self.nodes[self.selected]
	node.effects = node.effects or {} -- @hack

	local params = {
	  child_field_add = true,
	  array_replace_name = function(key, value)
		local effect_type = value.type
		return tdengine.effect_names[effect_type]
	  end
	}
	self.effect_editor = imgui.extensions.TableEditor(node.effects, params)
  end
  
  if node.kind == 'Branch' then
	imgui.InputTextSetContents(self.branch_on_id, node.branch_on)
  end

  if node.kind == 'If' then
	imgui.InputTextSetContents(self.branch_on_id, node.branch_on)
  end

  if node.kind == 'Switch' then
	imgui.InputTextSetContents(self.next_dialogue_id, node.next_dialogue)
  end
  
  if node.kind == 'Set' then
	imgui.InputTextSetContents(self.set_var_id, node.variable)
	imgui.InputTextSetContents(self.set_val_id, tostring(node.value))
  end
  
  if node.kind == 'ChoiceRepeat' then
	imgui.InputTextSetContents(self.internal_id_id, node.internal_id)
  end

  if node.kind == 'Return' then
	imgui.InputTextSetContents(self.return_to_id, node.return_to)
  end

  local text = ternary(node.text, node.text, node.variable)
  if node.kind == 'Text' or node.kind == 'Choice' then
	imgui.InputTextSetContents(self.input_id, text)
  else
	imgui.InputTextSetContents(self.input_id, '')
  end

  local text_editor = tdengine.find_entity('TextEditor')
  text_editor:set_text(node.text)

end

function DialogueEditor:input_slot(id)
  local gnode = self.layout_data[id]
  local canvas_world = tdengine.vec2(
	gnode.position.x,
	gnode.position.y + (gnode.size.y / 2))
  return self:canvas_world_to_window_screen(canvas_world)
end

function DialogueEditor:output_slot(id)
  local gnode = self.layout_data[id]
  local canvas_world = tdengine.vec2(
	gnode.position.x + gnode.size.x,
	gnode.position.y + (gnode.size.y / 2))
  return self:canvas_world_to_window_screen(canvas_world)
end

function DialogueEditor:select_entity(entity)
  self.selected = entity
  if self.selected then
	self.entity_editor = imgui.extensions.TableEditor(self.selected)
  end
end

-- Take a coordinate in canvas' world space and convert it to
-- the window's screen space (for DrawList)
function DialogueEditor:canvas_world_to_window_screen(canvas_world)
  local canvas_screen = canvas_world:add(self.scrolling)
  local window_screen = canvas_screen:add(self.window_position)
  return window_screen
end

-- Take a coordinate in the canvas' screen space and convert it to
-- the window's screen space
function DialogueEditor:canvas_screen_to_window_screen(canvas_screen)
  local window_screen = canvas_screen:add(self.window_position)
  return window_screen
end

