local glfw = require('glfw')

-- Adding a new node:
--
-- Editor methods:
-- * Editor::make_dialogue_node()
-- * Editor::ded_short_text()
-- * Editor::ded_select()
-- * Selected node detail view
--   * Add ID for text boxes in detail view
-- * (Maybe) Add custom node drawing
--
tdengine.node_kinds = {
  'Text',
  'Choice',
  'Set',
  'Branch',
  'Switch',
  'Empty'
}
					 

local state = {
  -- When the current node is a text node, we must wait until the user says OK to move on in the dialogue
  waiting_for_next   = 'waiting_for_next',
  -- When the current node is a choice node, we must wait until the user selects one
  waiting_for_choice = 'waiting_for_choice',
  -- Signals that the controller needs to make the transition from this node to the next node
  advancing          = 'advancing',
  -- Signals that the current node requires more than 1 frame of processing to complete, and we are in the middle of that
  processing         = 'processing'
}

local DialogueController = tdengine.entity('DialogueController')
function DialogueController:init(params)
  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.Game)
  self.input:enable()
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
  self.state = state.advancing
  
  self.hovered = 0
  tdengine.set_hovered_choice(self.hovered)
  
  self.current = nil

  -- Validation check. We should do this when the graph is saved, and more rigorously.
  local entry = self:find_entry_node()
  if not entry then
	tdengine.log(string.format('no entry node found, dialogue = %s', self.which))
	self.error = true
	return
  end
  if entry and entry.kind == 'Choice' then
	tdengine.log(string.format('choice nodes cannot be entry points, dialogue = %s', self.which))
	self.error = true
	return
  end
end

-- From the current node, figure out what the next node is and move to it
function DialogueController:advance()
  if not self.current then
	self.current = self:find_entry_node()
	return
  end
  if self.current.kind == 'Text' then
	local child_id = self.current.children[1]
	self.current = self.data[child_id]
	return
  end
  if self.current.kind == 'Switch' then
	tdengine.log(string.format('called advance on a switch node, uuid = %d', node.uuid))
	return
  end
  if self.current.kind == 'Set' then return end
  if self.current.kind == 'Branch' then return end
end

-- Enter a new node. If the node does not change the state of the controller, then the
-- controller will continue to advance through nodes. If a node requires processing to
-- complete, it should set the state accordingly
function DialogueController:enter()
  if self.current.kind == 'Text' then
	self.state = state.processing
	local request = {
	  text = self.current.text
	}
	tdengine.submit_text(request)
	return
  end
  if self.current.kind == 'Switch' then
	self:begin(self.current.next_dialogue)
	return
  end
  if self.current.kind == 'Set' then return end
  if self.current.kind == 'Branch' then return end
end

function DialogueController:process()
  if self.current.kind == 'Text' then
	local are_effects_done = true -- You'll need a way to query this from C++
	local continue = self.input:was_pressed(glfw.keys.SPACE)
	if are_effects_done and continue then
	  self.state = state.advancing
	end
	return
  end
  
  if self.current.kind == 'Set' then end
  if self.current.kind == 'Branch' then return end
end

function DialogueController:update(dt)
  if self.error then return end

  if self.state == state.waiting_for_choice then
	-- Move around and select choices, or skip to end of dialogue
	if self.input:was_pressed(glfw.keys.I) then
	  self.hovered = math.max(self.hovered - 1, 0)
	end
	if self.input:was_pressed(glfw.keys.I) then
	  self.hovered = self.hovered + 1
	end
	tdengine.set_hovered_choice(self.hovered)
	
  elseif self.state == state.waiting_for_next then
	
  
  elseif self.state == state.advancing then
	-- Advance nodes until you encounter one that requires processing
	while self.state == state.advancing do
	  self:advance()
	  self:enter()
	end

  elseif self.state == state.processing then
	-- Process the current node
	self:process()
  end
end

function DialogueController:find_entry_node()
   for id, node in pairs(self.data) do
	  local is_entry_point = node.is_entry_point or false
	  if is_entry_point then
		 return node
	  end
   end

   return nil
end
