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


function tdengine.load_dialogue(name_or_path)
  if name_or_path == nil then
	tdengine.log_to('could not load dialogue, name = nil', tdengine.log_flags.console)	
	return nil
  end

  local dialogue = nil
  if string.find(name_or_path, '/') or string.find(name_or_path, '\\') then
	dialogue = loadfile(name_or_path)
  else
	dialogue = loadfile(tdengine.paths.dialogue(name_or_path))
  end
  
  if not dialogue then
	local message = string.format('could not load dialogue, path = %s', tdengine.paths.dialogue(name_or_path))
	tdengine.log_to(message, tdengine.log_flags.console)	
	return nil
  end
  
  return dialogue()
end
