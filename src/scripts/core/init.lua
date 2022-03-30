inspect = require('inspect')
dbg = require('debugger')
dbg.auto_where = 3

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
  if name == nil then
	tdengine.log_to('could not load dialogue, name = nil', tdengine.log_flags.console)	
	return nil
  end
  
  local dialogue = loadfile(tdengine.paths.dialogue(name))
  if not dialogue then
	local message = string.format('could not load dialogue, path = %s', tdengine.paths.dialogue(name))
	tdengine.log_to(message, tdengine.log_flags.console)	
	return nil
  end
  
  return dialogue()
end
