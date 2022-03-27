inspect = require('inspect')

function tdengine.initialize()
  tdengine.screen('1440')
  tdengine.seed()
  tdengine.engine_stats = {}
  
  -- Load up static data
  tdengine.load_default_state()
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

function tdengine.handle_error(message)
  -- Strip the message to just the script filename to make it more readable
  local parts = split(message, ' ')
  local path = parts[1]
  local path_elements = split(path, '/')
  local filename = path_elements[#path_elements]

  local output = filename
  for index = 2, #parts do
	output = output .. ' ' .. parts[index]
  end

  -- And pass that into C++
  return output
end
