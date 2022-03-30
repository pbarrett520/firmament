local glfw = require('glfw')

local DialogueController = tdengine.entity('DialogueController')
function DialogueController:init(params)
end

function DialogueController:begin(which)
  self.error = false

  -- Grab the name of the dialogue we should run and try to load it
  self.which = which
  if not self.which then
	local message = string.format('controller got bad dialogue param, dialogue = %s', which)
	tdengine.log_to(message, tdengine.log_flags.console)
	self.error = true
	return
  end
  
  self.data = tdengine.load_dialogue(self.which)
  if not self.data then self.error = true; return end

  -- Parameters for traversing the tree
  self.waiting_for_input = false
  self.hovered = 0
  self.current = self:find_entry_node()
  if not self.current then
	local message = string.format('no entry node found, dialogue = ', self.which)
	tdengine.log_to(message, tdengine.log_flags.console)
	return
  end
  if entry and entry.kind == 'Choice' then
	message = string.format('choice nodes cannot be entry points, dialogue = %s')
	tdengine.log_to(message, tdengine.log_flags.console)
	return
  end

  -- Input
  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.Game)
  self.input:enable()

  tdengine.set_hovered_choice(self.hovered)
  
  -- Error checking
  local message = nil
  
  if message then
	message = message .. 'Dialogue was: ' .. self.which
	tdengine.log_to(message, tdengine.log_flags.console)
	self.error = true
  end
end

function DialogueController:process()
  if node.kind == 'Text' then return end
  if node.kind == 'Set' then return end
  if node.kind == 'Branch' then return end
  if node.kind == 'Set' then return end
end

function DialogueController:update(dt)
  if self.error then return end

  -- Move around and select choices, or skip to end of dialogue
  if self.waiting_for_input then
	if self.input.was_pressed(glfw.keys.I) then
	  self.hovered = math.max(self.hovered - 1, 0)
	end
	if self.input.was_pressed(glfw.keys.I) then
	  self.hovered = self.hovered + 1
	end
	tdengine.set_hovered_choice(self.hovered)
  else
	-- Process nodes until you are waiting for input
  end
end
