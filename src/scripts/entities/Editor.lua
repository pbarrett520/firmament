local glfw = require('glfw')
local inspect = require('inspect')

local effect_types = { 'oscillate', 'rainbow' }

local Editor = tdengine.entity('Editor')
function Editor:init(params)
  self.options = {
	show_imgui_demo = false,
  }
  
  self.ded = {
	nodes = {},
	layout_data = {},
	loaded = '',
	selected = nil,
	connecting = nil,
	disconnecting = nil, 
	deleting = nil,
	scrolling = tdengine.vec2(0, 0),
	scroll_per_second = 100,
	window_position = tdengine.vec2(0, 0),
	input_id = '##ded_editor',
	text_who_id = '##ded:detail:set_entity',
	set_var_id = '##ded:detail:set_var',
	set_val_id = '##ded:detail:set_val',
	internal_id_id = '##ded:detail:set_internal_id',
	return_to_id = '##ded:detail:set_return_to',
	branch_on_id = '##ded:detail:set_branch_var',
	next_dialogue_id = '##ded:detail:next_dialogue',
	branch_val_id = '##ded:detail:set_branch_val',
	empty_name_id = '##ded:detail:set_empty_name',
	selected_editor = nil,
	effect_editor = nil,
	selected_effect = 1
  }

  self.filter = imgui.TextFilter.new()
  self.id_filter = imgui.TextFilter.new()
  self.state_filter = imgui.TextFilter.new()

  self.selected = nil
  self.entity_editor = nil
  self.state_editor = imgui.extensions.TableEditor(tdengine.state)
  self.display_framerate = 0
  self.average_framerate = 0
  self.frame = 0

  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.Editor)
  self.input:enable()

  self.imgui_ignore = {
	state_editor = true,
	entity_editor = true,
	imgui_ignore = true
  }
  
  tdengine.create_entity('OptionUpdater')
end

function Editor:update(dt)
  submit_dbg_tbox()

  
  tdengine.do_once(function() submit_dbg_text() end)

  
  self:calculate_framerate()
  self:handle_input()

  imgui.SetNextWindowSize(300, 300)

  self:engine_viewer()
  self:state_viewer()
  self:scene_viewer()
  self:dialogue_editor(dt)
end

function Editor:handle_input()
  -- If we're in ImGui mode, the input won't be reported to editor channel
  if self.input:was_pressed(glfw.keys.RIGHT_ALT, tdengine.InputChannel.ImGui) then
    tdengine.toggle_console()
  end

  if self.input:was_pressed(glfw.keys.RIGHT_ALT) then
    tdengine.toggle_console()
  end

  local channels = { tdengine.InputChannel.ImGui, tdengine.InputChannel.Editor }
  for i, channel in pairs(channels) do
	if self.input:chord(glfw.keys.ALT, glfw.keys.J, channel) then
	  tdengine.previous_layout()
	end
	if self.input:chord(glfw.keys.ALT, glfw.keys.L, channel) then
	  tdengine.next_layout()
	end
  end
end

function Editor:engine_viewer()
  imgui.Begin('engine', true)
  
  imgui.Text('frame: ' .. tostring(self.frame))
  imgui.Text('fps: ' .. tostring(self.display_framerate))

  local screen_size = tdengine.screen_dimensions()
  imgui.extensions.Vec2('screen size', screen_size)

  local cursor = tdengine.vec2(tdengine.cursor()):truncate(3)
  imgui.extensions.Vec2('cursor', cursor)

  imgui.extensions.Table(tdengine.engine_stats.scroll);
  
  imgui.End()
end

function Editor:draw_entity_viewer()
  self.filter:Draw("Filter by name")
  local entity_hovered_in_list = nil

  local sorted_ids = {}
  for id, entity in pairs(tdengine.entities) do
	table.insert(sorted_ids, id)
  end

  local compare_entity_ids = function(a, b)
	local entity_a = tdengine.entities[a]
	local entity_b = tdengine.entities[b]

	local name_a = entity_a:get_name()
	local name_b = entity_b:get_name()
	if name_a == name_b then
	  return entity_a.id < entity_b.id
	else
	  return name_a < name_b
	end
  end
  table.sort(sorted_ids, compare_entity_ids)
  
  for index, id in pairs(sorted_ids) do
	local entity = tdengine.entities[id]
	local sid = tostring(id)

	local pass = false
	pass = pass or self.filter:PassFilter(entity.name)
	pass = pass or self.filter:PassFilter(sid)
	pass = pass or (tag and self.filter:PassFilter(entity.tag))
	if pass then
	  imgui.PushID(id .. '##list_view')

	  -- Display the node, and if clicked select it
	  if self.selected == entity then
		--imgui.PushStyleColor_2(imgui.constant.Col.Text, 0, 1, .1, 1)
	  end
	  
	  if imgui.MenuItem(entity.name) then
		self:select_entity(entity)
	  end

	  --imgui.PopStyleColor()

	  imgui.PopID()
	end
  end
end

function Editor:scene_viewer()
  imgui.Begin("scene", true)
  self:draw_entity_viewer()
  imgui.extensions.WhitespaceSeparator(10)
  self:draw_selected_entity()
  imgui.End()
end

function Editor:draw_selected_entity()
  if self.selected ~= nil then
	self.entity_editor:draw()
  end
end

function Editor:make_dialogue_node(kind)
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
	node.branch_on = 'buns'
  elseif kind == 'Switch' then
	node.next_dialogue = 'empty_switch'
  elseif kind == 'ChoiceRepeat' then
	node.internal_id = 'Set this to an ID you can refer to from a Return node'
  elseif kind == 'Return' then
	node.return_to = 'Set this to an ID you used for the internal_id of another node. Autogenerated UUID also works.'
  end
  
  return node

end

function Editor:ded_load(name)
  if #name == 0 then return end
  self.ded.loaded = name
  self.ded.selected = nil
  self.ded.connecting = nil
  self.ded.disconnecting = nil
  self.ded.deleting = nil
  self.ded.scrolling = tdengine.vec2(0, 0)
  imgui.InputTextSetContents(self.ded.input_id, '')

  self.ded.nodes = tdengine.load_dialogue(name)
  if not self.ded.nodes then
	self.ded.nodes = {}
	return
  end
  
  -- Load the GUI data
  self.ded.layout_data = dofile(tdengine.paths.dialogue_layout(name))
  if not self.ded.layout_data then
	self.ded.nodes = {}
	self.self.ded.layout_data = {}
	
	tdengine.log('no gui layout for dialogue, path = ' .. layout_path)
	return
  end
end

function Editor:ded_save(name)
  if #name == 0 then return end
  local serpent = require('serpent')

  -- Save out the engine data
  local data_path = tdengine.paths.dialogue(name)
  local data_file = io.open(data_path, 'w')
  if data_file then
	data_file:write('return ')
	data_file:write(serpent.block(self.ded.nodes, { comment = false }))
	data_file:close()
  else
	print('ded_save(): could not open data file: ' .. data_path)
  end

  -- Save out the layout data
  local layout_path = tdengine.paths.dialogue_layout(name)
  local layout_file = io.open(layout_path, 'w')
  if layout_file then
	layout_file:write('return ')
	layout_file:write(serpent.block(self.ded.layout_data, { comment = false }))
	layout_file:close()
  else
	print('ded_save(): could not open gui node data: ' .. layout_path)		 
  end
end

function Editor:ded_new(name)
  if not name then
	print('ded_new(): no name')
	return
  end
  if #name == 0 then
	print('ded_new(): empty name')
	return
  end

  self.ded.nodes = {}
  self:ded_save(name)
  self:ded_load(name)
end

function Editor:ded_short_text(node)
  local max_size = 16
  if node.kind == 'Text' or node.kind == 'Choice' then
	if string.len(node.text) < max_size then
	  return string.sub(node.text, 0, max_size)
	else
	  return string.sub(node.text, 0, max_size - 3) .. '...'
	end
  elseif node.kind == 'Set' then
	 return node.variable .. ' = ' .. tostring(node.value)
  elseif node.kind == 'Empty' then
	 return node.internal_name
  elseif node.kind == 'Branch' then
	 return node.branch_on
  elseif node.kind == 'Switch' then
	 return node.next_dialogue
  elseif node.kind == 'ChoiceRepeat' then
	 return node.internal_id
  elseif node.kind == 'Return' then
	 return node.return_to
  else
	print('Editor:ded_short_text(): missing entry: ' .. node.kind)
  end
end

function Editor:ded_full_path()
  if string.len(self.ded.loaded) > 0 then
	return 'src/scripts/dialogue/' .. self.ded.loaded .. '.lua'
  end

  return 'no file loaded'
end

function Editor:ded_select(id, node)
  self.ded.selected = id
  if not self.ded.selected then
	self.ded.selected_editor = nil
	return
  end

  self.ded.selected_editor = imgui.extensions.TableEditor(self.ded.nodes[id])

  if node.kind == 'Empty' then
	imgui.InputTextSetContents(self.ded.empty_name_id, node.internal_name)
  end

  if node.kind == 'Text' then
	imgui.InputTextSetContents(self.ded.text_who_id, node.who)
	self.ded.selected_editor.imgui_ignore = {
	  text = true,
	  effects = true
	}
	local node = self.ded.nodes[self.ded.selected]
	node.effects = node.effects or {} -- @hack

	local params = {
	  child_field_add = true,
	  array_replace_name = function(key, value)
		local effect_type = value.type
		return effect_types[effect_type]
	  end
	}
	self.ded.effect_editor = imgui.extensions.TableEditor(node.effects, params)
  end
  
  if node.kind == 'Branch' then
	imgui.InputTextSetContents(self.ded.branch_on_id, node.branch_on)
  end

  if node.kind == 'Switch' then
	imgui.InputTextSetContents(self.ded.next_dialogue_id, node.next_dialogue)
  end
  
  if node.kind == 'Set' then
	imgui.InputTextSetContents(self.ded.set_var_id, node.variable)
	imgui.InputTextSetContents(self.ded.set_val_id, tostring(node.value))
  end
  
  if node.kind == 'ChoiceRepeat' then
	imgui.InputTextSetContents(self.ded.internal_id_id, node.internal_id)
  end

  if node.kind == 'Return' then
	imgui.InputTextSetContents(self.ded.return_to_id, node.return_to)
  end

  local text = ternary(node.text, node.text, node.variable)
  if node.kind == 'Text' or node.kind == 'Choice' then
	imgui.InputTextSetContents(self.ded.input_id, text)
  else
	imgui.InputTextSetContents(self.ded.input_id, '')
  end
end

function Editor:input_slot(id)
  local gnode = self.ded.layout_data[id]
  local canvas_world = tdengine.vec2(
	gnode.position.x,
	gnode.position.y + (gnode.size.y / 2))
  return self:canvas_world_to_window_screen(canvas_world)
end

function Editor:output_slot(id)
  local gnode = self.ded.layout_data[id]
  local canvas_world = tdengine.vec2(
	gnode.position.x + gnode.size.x,
	gnode.position.y + (gnode.size.y / 2))
  return self:canvas_world_to_window_screen(canvas_world)
end

function Editor:dialogue_editor(dt)
  imgui.Begin('dialogue', true)

  -- Draw the sidebar
  imgui.BeginChild('sidebar', 400, 0)
  
  imgui.Text(self:ded_full_path())

  -- Buttons: Save, Save As, Load, New
  local button_size = { x = 100, y = 0 }

  if imgui.Button('Save', button_size.x, button_size.y) then
	self:ded_save(self.ded.loaded)
  end

  local id = '##ded_save_as'
  local save = false
  save = save or imgui.Button('Save As', button_size.x, button_size.y)
  imgui.SameLine()
  save = save or imgui.InputText(id)
  if save then
	self:ded_save(imgui.InputTextContents(id))
	self.ded.loaded = imgui.InputTextContents(id)
	imgui.InputTextClear(id)
  end

  id = '##ded_load'
  local do_load = imgui.Button('Load', button_size.x, button_size.y)
  imgui.SameLine()
  do_load = do_load or imgui.InputText(id)
  if do_load then
	-- Because you can still click this and have the grid hidden
	tdengine.layout('ded') 

	self:ded_load(imgui.InputTextContents(id))
	imgui.InputTextClear(id)
  end

  id = '##ded_new'
  local do_new = imgui.Button('New', button_size.x, button_size.y)
  imgui.SameLine()
  do_new = do_new or imgui.InputText(id)
  if do_new then
	-- Because you can still click this and have the grid hidden
	tdengine.layout('ded') 

	self:ded_new(imgui.InputTextContents(id))
	imgui.InputTextClear(id)
  end

  id = '##ded_run'
  if imgui.Button('Run', button_size.x, button_size.y) then
	tdengine.layout('tiny')
	local controller = tdengine.find_entity('DialogueController')
	if controller then
	  tdengine.destroy_entity(controller.id)
	end
	self:select_entity(nil)
	
	if self.ded.loaded then
	  local eid = tdengine.create_entity('DialogueController')
	  local controller = tdengine.find_entity('DialogueController')
	  controller:begin(self.ded.loaded)
	  
	  tdengine.clear_mtb()
	  tdengine.clear_choices()
	end
  end

  imgui.Separator()
  
  -- Selected node detail view
  local selected = self.ded.selected and self.ded.nodes[self.ded.selected]
  if selected then
	self.ded.selected_editor:draw()

	if selected.kind == 'Text' or selected.kind == 'Choice' then
	  imgui.extensions.VariableName('text')
	  imgui.SameLine()

	  imgui.PushTextWrapPos(0)
	  imgui.Text(imgui.InputTextContents(self.ded.input_id))
	  imgui.PopTextWrapPos()

	  imgui.Dummy(0, 10)
	  imgui.Separator()
	  imgui.Dummy(0, 10)
	  
	  imgui.PushItemWidth(250)
	  if imgui.BeginCombo('##combo', effect_types[self.ded.selected_effect]) then
		for i, effect_type in pairs(effect_types) do
		  local selected = i == self.ded.selected_effect
		  if imgui.Selectable(effect_type, selected) then
			self.ded.selected_effect = i
		  end

		  if selected then imgui.SetItemDefaultFocus() end
		end
		imgui.EndCombo()
	  end
	  imgui.PopItemWidth()

	  imgui.SameLine()
	  if imgui.Button('Add Effect') then
		table.insert(selected.effects, { type = self.ded.selected_effect })
	  end

	  if imgui.TreeNode('effects') then
		self.ded.effect_editor:draw()
		imgui.TreePop()
	  end
	end
  end
  
  imgui.Dummy(0, 10)
  imgui.Separator()
  imgui.Dummy(0, 10)

  -- A list of all nodes, just using their short names
  local node_hovered_in_list = nil
	for id, node in pairs(self.ded.nodes) do
	  local imid = id .. 'list_view'
	  imgui.PushID(imid)

	  -- Write the selected node in a different color
	  local pushed_color = false
	  if self.ded.selected == id then
		local hl_color = tdengine.color32(0, 255, 0, 255)
		imgui.PushStyleColor(imgui.constant.Col.Text, hl_color)
		pushed_color = true
	  end

	  -- Display the node, and if clicked select it
	  if imgui.MenuItem(self:ded_short_text(node)) then
		self:ded_select(id, node)
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
  
  imgui.BeginChild('scrolling_region', 0, -200, true, flags)
  self.ded.window_position = tdengine.vec2(imgui.GetCursorScreenPos())

  -- Draw the grid
  local cursor_x, cursor_y = imgui.GetCursorScreenPos()
  local offset = tdengine.vec2(
	self.ded.scrolling.x + cursor_x,
	self.ded.scrolling.y + cursor_y)
  local line_color = tdengine.color32(200, 200, 200, 40)
  local grid_size = 64
  local wsx, wsy = imgui.GetWindowSize()

  for off_x = math.fmod(self.ded.scrolling.x, grid_size), wsx, grid_size do
	local top = tdengine.vec2(off_x, 0)
	top = self:canvas_screen_to_window_screen(top)
	
	local bottom = tdengine.vec2(off_x, wsy)
	bottom = self:canvas_screen_to_window_screen(bottom)
	
	imgui.DrawList_AddLine(top.x, top.y, bottom.x, bottom.y, line_color)
  end

  for off_y = math.fmod(self.ded.scrolling.y, grid_size), wsy, grid_size do
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

  for id, node in pairs(self.ded.nodes) do
	imgui.PushID(id)

	-- GUI data stored separately from actual game data
	local gnode = self.ded.layout_data[id]
	local canvas_position = tdengine.vec2(gnode.position.x, gnode.position.y)

	local node_rect_min = self:canvas_world_to_window_screen(canvas_position)
	local node_contents_cursor = node_rect_min:add(node_padding)
	
	-- Draw the node contents
	imgui.DrawList_ChannelsSetCurrent(2)

	local old_any_active = imgui.IsAnyItemActive()

	imgui.SetCursorScreenPos(node_contents_cursor:unpack())

	-- Add any custom GUI items for each node kind
	imgui.BeginGroup()
	if node.kind == 'Text' then
	  imgui.Text(node.who)
	else
	  imgui.Text(node.kind)
	end
	imgui.Text(self:ded_short_text(node))
	imgui.EndGroup()

	local contents_size = tdengine.vec2(imgui.GetItemRectSize())
	local padding_size = node_padding:scale(2)
	gnode.size = contents_size:add(padding_size)
	local node_rect_max = node_rect_min:add(gnode.size)
	
	-- Set up the 'button' that makes up the node
	imgui.SetCursorScreenPos(node_rect_min:unpack())
	imgui.InvisibleButton('node', gnode.size:unpack())

	-- Figure out whether we're pressed, hovered, or dragged
	local pressed = imgui.IsItemClicked()
	if pressed then
	  self:ded_select(id, node)

	  -- If someone left clicked us, check whether they're trying to
	  -- (dis)connect themselves to you
	  if imgui.IsMouseClicked(0) then
		if self.ded.connecting then
		  local parent = self.ded.nodes[self.ded.connecting]
		  table.insert(parent.children, id)
		  self.ded.connecting = nil
		end
		if self.ded.disconnecting then
		  local parent = self.ded.nodes[self.ded.disconnecting]
		  delete(parent.children, id)
		  self.ded.disconnecting = nil
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
		self.ded.connecting = id
	  end
	  if imgui.MenuItem('Disconnect') then
		self.ded.disconnecting = id
	  end
	  if imgui.MenuItem('Set as entry point') then
		for i, node in pairs(self.ded.nodes) do
		  node.is_entry_point = false
		end

		node.is_entry_point = true
	  end

	  if imgui.MenuItem('Delete') then
		self.ded.deleting = id
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
	
	local highlight = hovered or node.uuid == self.ded.selected
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

  for id, node in pairs(self.ded.nodes) do
	local output_slot = self:output_slot(id)
	local use_dc_prompt_color = self.ded.disconnecting == id
	
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

  if self.ded.connecting then
	local p0 = self:output_slot(self.ded.connecting)
	local cursor = tdengine.vec2(imgui.GetMousePos())

	imgui.DrawList_AddBezierCurve(
	  p0.x, p0.y,
	  p0.x + 50, p0.y + 50,
	  cursor.x - 50, cursor.y - 50,
	  cursor.x, cursor.y,
	  link_color, thickness)
  end

  imgui.DrawList_ChannelsMerge()

  if self.ded.deleting then
	for id, node in pairs(self.ded.nodes) do
	  delete(node.children, self.ded.deleting)
	end
	
	self:ded_select(ternary(self.ded.selected == self.ded.deleting, nil, self.ded.selected))
	self.ded.connecting = ternary(self.ded.connecting == self.ded.deleting, nil, self.ded.selected)
	self.ded.disconnecting = ternary(self.ded.disconnecting == self.ded.deleting, nil, self.ded.selected)

	self.ded.nodes[self.ded.deleting] = nil
	self.ded.deleting = nil
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
		self.ded.nodes[node.uuid] = node

		local mouse = tdengine.vec2(imgui.GetMousePos())
		self.ded.layout_data[node.uuid] = {
		  position = mouse:subtract(self.ded.window_position):subtract(self.ded.scrolling),
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
		self.ded.scrolling = self.ded.scrolling:add(delta)
	 end

	 self.input:set_channel(tdengine.InputChannel.ImGui)

	 self.ded.scroll_per_second = 1000
	 local delta = tdengine.vec2(0, 0)
 	 if self.input:is_down(glfw.keys.W) then
		delta.y = delta.y + (self.ded.scroll_per_second * dt)
	 end
 	 if self.input:is_down(glfw.keys.S) then
		delta.y = delta.y - (self.ded.scroll_per_second * dt)
	 end
 	 if self.input:is_down(glfw.keys.A) then
		delta.x = delta.x + (self.ded.scroll_per_second * dt)
	 end
 	 if self.input:is_down(glfw.keys.D) then
		delta.x = delta.x - (self.ded.scroll_per_second * dt)
	 end
	 
	 self.input:set_channel(tdengine.InputChannel.Editor)

	 self.ded.scrolling = self.ded.scrolling:add(delta)
  end

  imgui.EndChild()

  -- @hack: 0 doesn't infer like I'd expect it to
  imgui.InputTextMultiline(self.ded.input_id, 1024, -1, -1)
  if self.ded.selected then
	local selected = self.ded.nodes[self.ded.selected]
	if selected.kind == 'Text' or selected.kind == 'Choice' then
	  selected.text = imgui.InputTextContents(self.ded.input_id)
	end
  end


  imgui.PopStyleVar()   -- FramePadding
  imgui.PopStyleVar()   -- WindowPadding
  imgui.PopStyleColor() -- ChildBg
  imgui.EndGroup()      -- Canvas

  imgui.End()
end

function Editor:state_viewer()
  imgui.Begin('state')

  -- If the underlying table changes, we're holding a stale reference
  if self.state_editor.editing ~= tdengine.state then
	self.state_editor = imgui.extensions.TableEditor(tdengine.state)
	print('reload state editor')
  end
  self.state_editor:draw()
  imgui.End('state')
end

function Editor:calculate_framerate()
  local framerate = tdengine.framerate or 0
  self.average_framerate = self.average_framerate * .5
  self.average_framerate = self.average_framerate + framerate * .5
  self.frame = self.frame + 1
  if self.frame % 20 == 0 then
	self.display_framerate = self.average_framerate
  end   
end

function Editor:select_entity(entity)
  self.selected = entity
  if self.selected then
	self.entity_editor = imgui.extensions.TableEditor(self.selected)
  end
end

-- Take a coordinate in canvas' world space and convert it to
-- the window's screen space (for DrawList)
function Editor:canvas_world_to_window_screen(canvas_world)
  local canvas_screen = canvas_world:add(self.ded.scrolling)
  local window_screen = canvas_screen:add(self.ded.window_position)
  return window_screen
end

-- Take a coordinate in the canvas' screen space and convert it to
-- the window's screen space
function Editor:canvas_screen_to_window_screen(canvas_screen)
  local window_screen = canvas_screen:add(self.ded.window_position)
  return window_screen
end


function crash()
  	local x = {}
	x()
end

function submit_oscillate(text)
  local request = {
	text = text,
	character = tdengine.characters.narrator,
	effect = {
	  type = 1,
	  amplitude = .003,
	  frequency = 15
	}
  }
  tdengine.submit_text(request)
end

function submit_rainbow(text, first, last)
  first = first or 0
  last = last or 3
  local request = {
	text = text,
	character = tdengine.characters.narrator,
	effects = {
	  {
		type = 2,
		first = first,
		last = last,
		frequency = 15
	  }
	}
  }
  tdengine.submit_text(request)
end

function submit_full_rainbow(text)
  local request = {
	text = text,
	character = tdengine.characters.narrator,
	effects = {
	  {
		type = 2,
		frequency = 15
	  }
	}
  }
  tdengine.submit_text(request)
end

function submit_without_effect(text)
  local request = {
	text = text,
	character = tdengine.characters.narrator
  }
  tdengine.submit_text(request)
end

function submit_two_effects(text)
  local request = {
	text = text,
	character = tdengine.characters.narrator,
	effects = {
	  {
		type = 1,
		amplitude = .003,
		frequency = 15
	  },
	  {
		type = 2,
		frequency = 15
	  }
	}
  }
  tdengine.submit_text(request)
end

function submit_two_effects_no_overlap(text)
  local request = {
	text = text,
	character = tdengine.characters.narrator,
	effects = {
	  {
		type = 1,
		amplitude = .003,
		frequency = 15,
		first = 0,
		last = 3
	  },
	  {
		type = 2,
		frequency = 15,
		first = 4,
		last = 20
	  }
	}
  }
  tdengine.submit_text(request)
end

function submit_multiline_plain()
  submit_without_effect('joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. ')
end

function submit_multiline_rainbow()
  submit_rainbow('joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. joey, the striker fox. ')
end

function submit_dbg_text()
  --submit_two_effects('joey, the striker fox')
  --submit_two_effects_no_overlap('joey, the striker fox')
  --submit_full_rainbow('joey, the striker fox')
  --submit_rainbow('joey, the striker fox')
  --submit_without_effect('joey, the striker fox')
  submit_multiline_plain()
  --submit_multiline_rainbow()
end

function submit_dbg_quad()
  local request = {
	type = 1,
	pos = tdengine.vec2(-.5, .5),
	color = tdengine.color(0, 0, 1, .5),
	size = tdengine.vec2(1, 1)
  }
  tdengine.submit_dbg_geometry(request)
end

function submit_dbg_tbox()
  local request = {
	type = 2,
	main = true,
	choice = true
  }
  tdengine.submit_dbg_geometry(request)
end
