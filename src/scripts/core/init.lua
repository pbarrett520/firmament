inspect = require('inspect')

function tdengine.initialize()
  tdengine.screen('1080')

  tdengine.seed()
  
  -- Set up globals
  tdengine.entities = {}
  tdengine.entity_types = {}
  tdengine.next_entity_id = 0
  tdengine.state = {}

  tdengine.current_layout = 'default'
  tdengine.layout_stack = { 'default' }
  tdengine.layout_index = 1
  
  tdengine.console_pipe = ''

  -- Load up static data
  tdengine.load_default_state()

  tdengine.log('tdengine.initialize: static initialization complete')
end

function tdengine.load_editor()
  tdengine.create_entity('Editor')
end

function tdengine.load_default_state()
  -- @firmament: define these paths in lua, load them into C++
  -- you'd have a hardcoded path for "state directory", a function to
  -- append a filename to a path, and then you just load the path
  -- like in confer paths -- hardcode/detect base path and build from there
  local state = tdengine.fetch_module_data('state/state')
  if not state then tdengine.log('@load_default_state_failure'); return end
  
  tdengine.state = state
end

function tdengine.load_dialogue(name)
  -- Load the dialogue data itself
  local filepath = 'dialogue/' .. name
  package.loaded[filepath] = nil
  
  local status, dialogue = pcall(require, filepath)
  if not status then
	local message = 'tdengine.load_dialogue() :: could not find dialogue. '
	message = message .. 'requested dialogue was: ' .. name
	print(message)

	return nil
  end
  
  return dialogue
end

