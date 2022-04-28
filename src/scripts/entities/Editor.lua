local glfw = require('glfw')
local inspect = require('inspect')

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

  self.do_layout_save = false
  self.ids = {
	save_layout = '##menu:save_layout'
  }

  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.Editor)
  self.input:enable()

  self.imgui_ignore = {
	state_editor = true,
	entity_editor = true,
	imgui_ignore = true
  }
  
  tdengine.create_entity('MainMenu')
  tdengine.create_entity('OptionUpdater')
  tdengine.create_entity('DialogueEditor')
end

function Editor:update(dt)
  local option_updater = tdengine.find_entity('OptionUpdater')
  if option_updater.this_frame.show_text_box then submit_dbg_tbox() end
  
  --tdengine.do_once(function() submit_dbg_text() end)
  
  self:calculate_framerate()
  self:handle_input()

  imgui.SetNextWindowSize(300, 300)

  -- Handle stuff from the main menu bar
  
  
  self:engine_viewer()
  self:state_viewer()
  self:scene_viewer()

  if need_update_selected_tab then
	print(last_selected_tab)
	imgui.MakeTabVisible(last_selected_tab)
	need_update_selected_tab = false
  end
end

function Editor:handle_input()
  -- If we're in ImGui mode, the input won't be reported to editor channel
  if self.input:was_pressed(glfw.keys.RIGHT_ALT, tdengine.InputChannel.All) then
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

function Editor:state_viewer()
  imgui.Begin('state')

  -- If the underlying table changes, we're holding a stale reference
  if self.state_editor.editing ~= tdengine.state then
	self.state_editor = imgui.extensions.TableEditor(tdengine.state)
  end
  self.state_editor:draw()
  imgui.End('state')
end

function Editor:select_entity(entity)
  self.selected = entity
  if self.selected then
	self.entity_editor = imgui.extensions.TableEditor(self.selected)
  end
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

function crash()
  	local x = {}
	x()
end

function submit_oscillate(text)
  local request = {
	text = text,
	character = tdengine.characters.narrator,
	effect = {
	  type = tdengine.effects.oscillate,
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
		type = tdengine.effects.rainbow,
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
		type = tdengine.effects.rainbow,
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
		type = tdengine.effects.oscillate,
		amplitude = .003,
		frequency = 15,
		first = 0,
		last = 3
	  },
	  {
		type = tdengine.effects.rainbow,
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
