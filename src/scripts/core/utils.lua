-- Utilities
tdengine.colors = {}
tdengine.colors.red =   { r = 1, g = 0, b = 0, a = 1 }
tdengine.colors.green = { r = 0, g = 1, b = 0, a = 1 }
tdengine.colors.blue =  { r = 0, g = 0, b = 1, a = 1 }
tdengine.colors.idk =   { r = 0, g = .75, b = 1, a = 1 }
tdengine.colors.grid_bg =  { r = .25, g = .25, b = .3, a = .8 }

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
	t2[k] = v
  end
  return t2
end

function table.flatten(t, parent)
  function child_key(parent, child)
	if #parent > 0 then
	  return string.format('%s.%s', parent, child)
	else
	  return child
	end
  end
  
  parent = parent or ''
  local flat = {}
  for name, value in pairs(t) do
	if type(value) == 'table' then
	  local children = table.flatten(value, child_key(parent, name))
	  for i, child in pairs(children) do
		table.insert(flat, child)
	  end
	else
	  table.insert(flat, child_key(parent, name))
	end
  end

  return flat
end

-- Copy all keys in source and all subtables into dest. Do not copy values
-- that already exist in dest. Also, remove all keys in dest that are not in
-- source. In other words, source is the canonical form, make dest comply.
function make_keys_match(source, dest)
  return add_source_keys(source, dest) or remove_dest_keys(source, dest)
end

function add_source_keys(source, dest)
  -- Copy source keys into dest
  local changed = false
  
  for key, value in pairs(source) do
	local continue = false
	
	-- Dest table doesn't have this key at all. Whether it's a table,
	-- or a single state field, we want to copy it from source
	if dest[key] == nil then
	  dest[key] = dest[key] or source[key]
	  changed = true
	  continue = true
	end

	-- Both tables could have a child table that have different keys,
	-- so we must recurse
	if type(value) == 'table' and not continue then
	  changed = changed or add_source_keys(source[key], dest[key])
	end
  end

  return changed
end

function remove_dest_keys(source, dest)
  -- Remove dest keys that are not in source
  local changed = false
  
  for key, value in pairs(dest) do
	local continue = false
	
	if source[key] == nil then
	  dest[key] = nil
	  changed = true
	  continue = true
	end
	
	if type(value) == 'table' and not continue then
	  changed = changed or remove_dest_keys(source[key], dest[key])
	end
  end
  
  return changed
end
  
function tdengine.platform()
  local separator = package.config:sub(1,1)
  if separator == '\\' then
	return 'Windows'
  elseif separator == '/' then
	return 'Unix'
  else
	return ''
  end
end

function tdengine.extract_filename(path)
  return path:match("([^/\\]+)$")
end

function tdengine.is_extension(path, extension)
  local ext_len = string.len(extension)
  local path_len = string.len(path)
  if ext_len > path_len then return false end

  local last = string.sub(path, path_len - ext_len + 1, path_len)
  return last == extension
end


function tdengine.has_extension(path)
  return string.find(path, '%.')
end

function tdengine.strip_extension(path)
  local extension = tdengine.has_extension(path)
  if not extension then return path end

  return path:sub(1, extension - 1)
end

function tdengine.scandir(dir)
  local platform = tdengine.platform()
  local command = ''
  if platform == 'Unix' then command = 'ls -a "' .. dir .. '"' end
  if platform == 'Windows' then command = 'dir "' .. dir .. '" /b' end

  local i, t, popen = 0, {}, io.popen
  local pfile = popen(command)
  for filename in pfile:lines() do
	if filename ~= '.' and filename ~= '..' then 
	  i = i + 1
	  t[i] = filename
	end
  end
  pfile:close()
  return t
end

function tdengine.fmodtime(path)
  local platform = tdengine.platform()
  if platform == 'Windows' then
	local filename = tdengine.extract_filename(path)
	path = path:sub(1, #path - #filename - 1)
	local platform_path = path:gsub('/', '\\')
	--local command = string.format('dir /T:W "%s" | FINDSTR /c:"/"', platform_path)
	local command = string.format('forfiles /P "%s" /M "%s" /C "cmd /c echo @fdate @ftime"', platform_path, filename)
	local pipe = io.popen(command)
	local output = pipe:read'*a'
	pipe:close()

	output = output:gsub('\n', '')
	output = split(output, ' ')
	print(inspect(output))

  elseif platform == 'Unix' then
	
  end
end

function tdengine.write_file_to_return_table(filepath, t)
  local file = assert(io.open(filepath, 'w'))
  if file then
	local serpent = require('serpent')
	file:write('return ')
	file:write(serpent.block(t, { comment = false }))
  else
	print('@cannot_open_file: ' .. filepath)
  end
end

function tdengine.fetch_module_data_impl(module_path, log)
  package.loaded[module_path] = nil
  local status, data = pcall(require, module_path)
  return status, data  
end

function tdengine.fetch_module_data(module_path, log)
  local status, data = tdengine.fetch_module_data_impl(module_path)
  if not status then
	tdengine.log('@module_load_failure')
	tdengine.log(data)
	return nil
  end

  return data
end

function tdengine.fetch_module_data_quiet(module_path)
  local status, data = tdengine.fetch_module_data_impl(module_path)
  if not status then
	return nil
  end

  return data
end

function tdengine.seed()
  math.randomseed(os.clock() * 1000000)
end

function tdengine.uuid()
  local random = math.random
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  local sub = function (c)
	local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
	return string.format('%x', v)
  end
  return string.gsub(template, '[xy]', sub)
end

function tdengine.uuid_imgui()
  local random = math.random
  local template ='##xxxxxxxx-xxxx-4xxx-yxxx'
  local sub = function (c)
	local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
	return string.format('%x', v)
  end
  return string.gsub(template, '[xy]', sub)
end

function tdengine.color(r, g, b, a)
  return { r = r, g = g, b = b, a = a }
end

function tdengine.color32(r, g, b, a)
  a = a * math.pow(2, 24)
  b = b * math.pow(2, 16)
  g = g * math.pow(2, 8)
  return r + g + b + a
end


local vec2_mixin = {
  unpack = function(self)
	return self.x, self.y
  end,
  add = function(self, other)
	return tdengine.vec2(self.x + other.x, self.y + other.y)
  end,
  subtract = function(self, other)
	return tdengine.vec2(self.x - other.x, self.y - other.y)
  end,
  scale = function(self, scalar)
	return tdengine.vec2(self.x * scalar, self.y * scalar)
  end,
  truncate = function(self, digits)
	return tdengine.vec2(truncate(self.x, digits), truncate(self.y, digits))
  end,
  abs = function(self)
	return tdengine.vec2(math.abs(self.x), math.abs(self.y))
  end,
  equals = function(self, other, eps)
	eps = eps or tdengine.deq_epsilon
	return double_eq(self.x, other.x, eps) and double_eq(self.y, other.y, eps)
  end
}

tdengine.vec2_impl = tdengine.define_class('vec2_impl')
tdengine.add_new_to_class(tdengine.vec2_impl, tdengine)
tdengine.vec2_impl:include(vec2_mixin)
tdengine.vec2 = function(x, y)
  local vec = tdengine.vec2_impl:new()

  if type(x) == 'table' then
	vec.x = x.x
	vec.y = x.y
	return vec
  else
	vec.x = x
	vec.y = y
	return vec
  end
end

function tdengine.frames(n)
  return n / 60
end

local do_once = {
  info = nil,
  args = nil
}

function tdengine.do_once(f, ...)
  local info = debug.getinfo(f)

  -- Edge case: First time we call this. Just run the function and mark down its info.
  if do_once.info == nil then
	f(...)
	do_once.info = debug.getinfo(f)
	do_once.args = { ... }
	return
  else
	local line_match = do_once.info.linedefined == info.linedefined
	local file_match = do_once.info.source == info.source
	local args_match = table_eq_shallow(do_once.args, { ... })
	local all_match =  line_match and file_match and args_match
	if not all_match then
	  f(...)
	  do_once.info = debug.getinfo(f)
	  do_once.args = { ... }
	  return
	end

  end
end

function delete(array, value)
  local len = #array
  
  for index, v in pairs(array) do
	if v == value then
	  array[index] = nil
	end
  end

  local next_available = 0
  for check = 1, len do
	if array[check] ~= nil then
	  next_available = next_available + 1
	  array[next_available] = array[check]
	end
  end

  for remove = next_available + 1, len do
	array[remove] = nil
  end
end

function contains(t, k)
  return t[k] ~= nil
end

function ternary(cond, if_true, if_false)
  if cond then return if_true else return if_false end
end

function average(a, b)
  return (a + b) / 2
end

tdengine.deq_epsilon = .00000001
function double_eq(x, y, eps)
  eps = eps or tdengine.deq_epsilon
  return math.abs(x - y) < eps
end

function is_newline(c)
  return c == '\n'
end

function is_space(c)
  return c == ' '
end

tdengine.op_or, tdengine.op_xor, tdengine.op_and = 1, 3, 4

function bitwise(oper, a, ...)
  -- base case 1: the parameter pack is empty. return nil to signal.
  if a == nil then
	return nil
  end

  local b = bitwise(oper, ...)

  -- base case 2: we're at the end of the parameter pack. just return yourself.
  if b == nil then
	return a
  end
  
  local r, m, s = 0, 2^31
  repeat
	s,a,b = a+b+m, a%m, b%m
	r,m = r + m*oper%(s-a-b), m/2
  until m < 1
  return r
end

function truncate(float, digits)
  local mult = 10 ^ digits
  return math.modf(float * mult) / mult
end

function split(str, sep)
  output = {}
  
  for match in string.gmatch(str, "([^" .. sep .. "]+)") do
	table.insert(output, match)
  end
  
  return output
end

function index_string(t, ks)
  local value = t
  local keys = split(ks, '.')
  for i, key in pairs(keys) do
	value = value[key]
  end

  return value
end

function parent(t, ks)
  local parent = t
  local keys = split(ks, '.')
  for i, key in pairs(keys) do
	if i == #keys then break end
	parent = parent[key]
  end

  return parent
end

function table_address(t)
  if not t then return '0x00000000' end
  return split(tostring(t), ' ')[2]
end

function current_function_name()
  return debug.getinfo(2)
end

function table_eq_shallow(t1, t2)
  for k, t1v in pairs(t1) do
	t2v = t2[k]
	if t1v ~= t2v then return false end
  end
  return true
end

function hash_table_entry(t, k)
  return string.format('%s.%s', table_address(t), k)
end
