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
  -- 'Skill',
  -- 'Roll'
}
					 

local state = {
  err      = 'err',
  -- Signals that the controller needs to make the transition from this node to the next node
  advancing  = 'advancing',
  -- Signals that the current node requires more than 1 frame of processing to complete, and we are in the middle of that
  processing = 'processing'
}

local DialogueController = tdengine.entity('DialogueController')
function DialogueController:init(params)
  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.Game)
  self.input:enable()
end

function DialogueController:begin(which)
  -- Grab the name of the dialogue we should run and try to load it
  self.which = which
  if not self.which then
	local message = string.format('controller got bad dialogue param, dialogue = %s', which)
	tdengine.log_to(message, tdengine.log_flags.console)
	self.state = state.err
	return
  end
  
  self.data = tdengine.load_dialogue(self.which)
  if not self.data then self.state = state.err; return end

  -- Parameters for traversing the tree
  self.state = state.advancing
  
  self.hovered = 1
  tdengine.set_hovered_choice(self.hovered)
  
  self.current = nil

  -- Validation check. We should do this when the graph is saved, and more rigorously.
  local entry = self:find_entry_node()
  if not entry then
	tdengine.log(string.format('no entry node found, dialogue = %s', self.which))
	self.state = state.err
	return
  end
  if entry and entry.kind == 'Choice' then
	tdengine.log(string.format('choice nodes cannot be entry points, dialogue = %s', self.which))
	self.state = state.err
	return
  end
end

-- From the current node, figure out what the next node is and move to it.
--
-- Don't change the state in this function -- the next node will decide what
-- the final state after this round of advancing is.
function DialogueController:advance()
  if not self.current then
	self.current = self:find_entry_node()
	return
  end

  function simple_advance(self)
	if are_choices_next(self.current) then
	  -- The next nodes are a set of choices. Wrap them in one node to make it easy to handle
	  local internal = {
		kind = 'InternalChoice',
		choices = collect_choices(self.current, self.data)
	  }
	  self.current = internal
	else
	  -- Easy case: We're linearly moving to the singular next node on this path. 
	  local child_id = self.current.children[1]
	  self.current = self.data[child_id]
	end
  end
  
  if self.current.kind == 'Text' then
	simple_advance(self)
	return
  end

  if self.current.kind == 'InternalChoice' then
	tdengine.clear_choices()
	local choice = self.current.choices[self.hovered]
	self.current = self.data[choice.children[1]]
	return
  end

  
  if self.current.kind == 'Switch' then
	tdengine.log(string.format('called advance on a switch node, uuid = %d', node.uuid))
	return
  end

  
  if self.current.kind == 'Set' then
	simple_advance(self)
	return
  end
  
  if self.current.kind == 'Branch' then return end
end


-- Enter a new node. If the node does not change the state of the controller, then the
-- controller will continue to advance through nodes. If a node requires processing to
-- complete, it should set the state accordingly
function DialogueController:enter()
  print(string.format('entering %s', self.current.kind))
  if self.current.kind == 'Text' then
	self.state = state.processing
	
	local request = {
	  text = self.current.text
	}
	tdengine.submit_text(request)
	return
  end

  
  if self.current.kind == 'InternalChoice' then
	self.state = state.processing
	
	tdengine.clear_choices()
	for index, choice in pairs(self.current.choices) do
	  local request = {
		text = choice.text
	  }
	  tdengine.submit_choice(request)
	end
	self.hovered = 1
	tdengine.set_hovered_choice(self.hovered - 1)
	return
  end

  
  if self.current.kind == 'Switch' then
	self:begin(self.current.next_dialogue)
	return
  end

  
  if self.current.kind == 'Set' then
	local parent = parent(tdengine.state, self.current.variable)
	local keys = split(self.current.variable, '.')
	local var_key = keys[#keys]
	parent[var_key] = self.current.value
	print(inspect(parent))
	return
  end
  
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

  if self.current.kind == 'InternalChoice' then
	if self.input:was_pressed(glfw.keys.I) then
	  self.hovered = math.max(self.hovered - 1, 1)
	end
	if self.input:was_pressed(glfw.keys.K) then
	  self.hovered = math.min(self.hovered + 1, #self.current.choices)
	end
	tdengine.set_hovered_choice(self.hovered - 1)

	if self.input:was_pressed(glfw.keys.SPACE) then
	  self.state = state.advancing
	end

	return
  end

  tdengine.log(string.format('called process on an incompatible node, node = %s', inspect(self.current)))
end

function DialogueController:update(dt)
  if self.state == state.err then
	return
  elseif self.state == state.advancing then
	--dbg()
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



function is_conditional(node)
  return node and node.kind == 'Branch'
end

function evaluate_branch(node, all_nodes)
  -- Base case
  if not is_conditional(node) then return node end

  -- Traverse the conditional, depending on what kind it is
  if node.kind == 'Branch' then
	local value = index_string(tdengine.state, node.branch_on)
	local index = ternary(value, 1, 2)
	local child = all_nodes[node.children[index]]
	return evaluate_branch(child, all_nodes)
  end

  tdengine.log(string.format('evaluate_branch: tried to recurse on an invalid node kind, node = %s', inspect(node)))
  return nil
end

function are_choices_next(node)
  -- This is not validation; that happens when the tree is saved. Instead, this is
  -- how we determine whether the next node we're visiting is a set of choices.
  -- This is slightly complicated, since there are other node types that can
  -- have more than one child (e.g. a branch)

  -- First step: Only certain nodes can have choices as their children. Easy check.
  local legal = false
  local legal_choice_parents = {
	'Text',
	'Set'
  }
  for index, kind in pairs(legal_choice_parents) do
	if node.kind == kind then legal = true end
  end
  if not legal then return false end

  -- Second step: You must have multiple children to have choices. This chould change in the future
  local has_multiple_children = #node.children > 1
  return has_multiple_children
end

function collect_choices(node, all_nodes)
  local stack = {}
  for index = #node.children, 1, -1 do
	table.insert(stack, all_nodes[node.children[index]])
  end

  local stack_pop = function()
	local out = stack[#stack]
	stack[#stack] = nil
	return out
  end
  
  local choices = {}
  while #stack > 0 do
	local child = stack_pop()
	
	if child.kind == 'Choice' then
	  -- Easy case: It's just a choice node. We don't have to check anything
	  table.insert(choices, child)
	elseif child.kind == 'Branch' then
	  -- More difficult: There is a conditional that may or may not hide a choice node. Evaluate
	  -- the conditional, and if it returns non-nil we need to keep traversing this path.
	  local evaluated = evaluate_branch(child, all_nodes)
	  table.insert(stack, evaluated)
	end
  end

  return choices
end
