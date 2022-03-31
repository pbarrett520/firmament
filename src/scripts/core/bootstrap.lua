inspect = require('inspect')
dbg = require('debugger')
dbg.auto_where = 3

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

function tdengine.bootstrap()
  tdengine.entities = {}
  tdengine.entity_types = {}
  tdengine.next_entity_id = 0
  tdengine.class_types = {}
  tdengine.state = {}
  tdengine.paths = {}
  tdengine.path_constants = {}

  tdengine.current_layout = { name = 'default', selected_tab = 0 }
  tdengine.layout_stack = { { name = 'default', selected_tab = 0 } }
  tdengine.layout_index = 1

  tdengine.console_pipe = ''
end
