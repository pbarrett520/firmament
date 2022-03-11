tdengine.console_shortcuts = {
  controls = {
	help = 'print basic controls',
	proc = function()
	  local message = ''
	  message = message .. 'right alt :: toggle the console\n'
	  message = message .. 'layout("default") :: use the default gui layout\n'
	  message = message .. 'ded("some_dialogue") :: load a dialogue + use dialogue editor layout\n'
	  message = message .. '\nthe gui is totally resizeable. put it however the fuck\n'
	  message = message .. 'you want then call save_layout("name") to save the layout.\n'
	  message = message .. 'use layout("name") to load it later.'
	  
	  
	  tdengine.console_pipe = message

	end
  },
  ded = {
	help = 'load a scene into the dialogue editor',
	proc = function(name)
	  tdengine.layout('ded')
	  local editor = tdengine.find_entity('Editor')
	  editor:ded_load(name)
	end
  },
  layout = {
	help = 'use a predefined imgui layout',
	proc = tdengine.layout
  },
  list = {
	help = 'list all commands and their help messages',
	proc = function()
	  local message = ''
	  for name, data in pairs(tdengine.console_shortcuts) do
		message = message .. name .. ': ' .. data.help .. '\n'
	  end
	  
	  tdengine.console_pipe = message
	end
  },
  ['load'] = {
	help = 'load a state file, as saved in scripts/save',
	proc = function(...) tdengine.load(...) end
  },
  q = {
	help = 'run a script as defined in src/scripts/layouts/console',
	proc = function(name)
	  local module_path = 'layouts/console/' .. name
	  package.loaded[module_path] = nil
	  local status, err = pcall(require, module_path)
	  if not status then
		local message = '@quickscript_error: ' .. name
		print(message)
		print(err)
	  end
	end
  },
  save = {
	help = 'save all runtime state to a file',
	proc = function(...) tdengine.save(...) end
  },
  save_layout = {
	help = 'save current imgui configuration as a layout',
	proc = tdengine.save_layout
  }
}

-- When we type stuff in the editor's console, it's really annoying to preface
-- everything with 'tdengine.', so just stick these few useful functions in the
-- global namespace
for name, data in pairs(tdengine.console_shortcuts) do
  _G[name] = data.proc
end
