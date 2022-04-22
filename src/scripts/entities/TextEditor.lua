local glfw = require('glfw')
local TextEditor = tdengine.entity('TextEditor')
function TextEditor:init(params)
  params = params or {}
  self.text = params.text or nil
  self.point = 0
  self.line_breaks = {}
  
  self.frame = 0
  self.blink_speed = 20
  self.blink_acc = 0
  self.blink = true

  self.repeat_delay = .3
  self.repeat_time = {}
	
  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.ImGui)
end

function TextEditor:update(dt)
  self.advance = tdengine.vec2(imgui.CalcTextSize('#'), imgui.GetTextLineHeightWithSpacing())
  self.frame = self.frame + 1
  
  imgui.Begin('Text Editor', true)
  if not self.text then imgui.End(); return end
  self:update_blink()
  
  -- Handle characters, backspaces, key commands, whatever
  if imgui.IsWindowFocused() then
	local queue = imgui.GetInputQueue()
	for i = 1, #queue do
	  self:handle_char(queue:at(i))
	end

	self:handle_check_repeat(dt, glfw.keys.BACKSPACE, self.handle_backspace, self)
	self:handle_check_repeat(dt, glfw.keys.LEFT, self.handle_left_arrow, self)
	self:handle_check_repeat(dt, glfw.keys.RIGHT, self.handle_right_arrow, self)
	self:handle_check_repeat(dt, glfw.keys.DOWN, self.handle_down_arrow, self)
	self:handle_check_repeat(dt, glfw.keys.UP, self.handle_up_arrow, self)

	if imgui.IsMouseClicked(0) then
	  self.point = self:mouse_to_point()
	end
  end

  -- Calculate line breaks
  self.line_breaks = { 1 }
  local i = 0
  local point = 0
  local max_length, max_height = imgui.GetWindowContentRegionMax()
  for j = 1, #self.text do
	point = point + self.advance.x

	local cstart = point + self.advance.x
	local cend = point + (self.advance.x * 2)
	if (cend > max_length) then
	  table.insert(self.line_breaks, j)
	  point = 0
	end
  end
  table.insert(self.line_breaks, #self.text + 1)

  -- Draw the text
  for i = 1, (#self.line_breaks - 1) do
	local low = self.line_breaks[i]
	local high = self.line_breaks[i + 1] - 1
	imgui.Text(self.text:sub(low, high))
  end
  imgui.End()
end

function TextEditor:set_text(text)
  self.text = text
  self.point = 1
  self.line_breaks = {}
end

function TextEditor:update_blink()
  self.blink_acc = self.blink_acc + 1
  if self.blink_acc == self.blink_speed then
	self.blink = not self.blink
	self.blink_acc = 0
  end

  if self.blink then
	local tl = self:point_to_screen()
	local dim = tdengine.vec2(self.advance.x, self.advance.y)
	local color = imgui.ColorConvertFloat4ToU32(0, 1, 0, 1)
	imgui.AddRectFilled(tl.x, tl.y, tl.x + dim.x, tl.y + dim.y, color)
  end
end

function TextEditor:handle_check_repeat(dt, key, f, ...)
  -- Always do it on the first press
  if self.input:was_pressed(key) then
	self.repeat_time[key] = self.repeat_delay
	f(...)
	return
  end

  -- Otherwise, check if we've hit the repeat threshold
  if self.input:is_down(key) then
	self.repeat_time[key] = self.repeat_time[key] - dt
	if self.repeat_time[key] <= 0 then f(...) end
  end
end

function TextEditor:handle_backspace()
  -- If the point is N, then we will delete character N - 1
  if self.point == 1 then return end

  -- Minus two because (A) we want the character before point and (B) sub is inclusive
  -- For example: point = 4 -> we want to delete character 3 -> substring [1, 2]
  local before = self.text:sub(1, self.point - 2)
  if self.point == #self.text then
	self.text = before
	self:prev_character()
	return
  end
	
  local after = self.text:sub(self.point, #self.text)
  self.text = before .. after
  self:prev_character()
end

function TextEditor:handle_left_arrow()
  self:prev_character()
end

function TextEditor:handle_right_arrow()
  self:next_character()
end

function TextEditor:handle_down_arrow()
  local line, index = self:point_to_line_index()
  if line == #self.line_breaks - 1 then
	self.point = #self.text + 1
	return
  end

  local next_line_start = self.line_breaks[line + 1]
  self.point = math.min(#self.text + 1, next_line_start + index - 1)
end

function TextEditor:handle_up_arrow()
  local line, index = self:point_to_line_index()
  if line == 1 then self.point = 1; return end

  local prev_line_start = self.line_breaks[line - 1]
  self.point = math.max(1, prev_line_start + index - 1)
end

function TextEditor:handle_char(c)
  -- The point defines where the next character will go. For example, if the point is at 1, then
  -- the next character inserted will be at index 1.
  self.text = self.text:sub(1, self.point - 1) .. c .. self.text:sub(self.point, #self.text)
  self:next_character()
end

function TextEditor:next_character()
  self.point = math.min(self.point + 1, #self.text + 1)
end

function TextEditor:prev_character()
  self.point = math.max(self.point - 1, 1)
end

function TextEditor:point_to_screen()
  local screen = tdengine.vec2(imgui.GetCursorScreenPos())
  
  if self.point == #self.text + 1 then
	local count_lines = #self.line_breaks - 2
	screen.y = screen.y + (self.advance.y * count_lines)
	local last_line_text_size = self:line_text_size(#self.line_breaks - 1)
	screen.x = screen.x + last_line_text_size
	return screen
  end
  
  local total = self.point
  for i = 1, #self.line_breaks - 1 do
	local line_size = self.line_breaks[i + 1] - self.line_breaks[i]
	if total > line_size then -- 
	  -- Case 1: The total is not on this line. Just advance downward, removing however many characters this line has 
	  total = total - line_size
	  screen.y = screen.y + self.advance.y
	elseif total == line_size then
	  -- Case 2: Same as above, but must return. Special case needed to avoid overflowing line break array
	  screen.x = screen.x + imgui.CalcTextSize(self.text:sub(self.line_breaks[i], self.line_breaks[i] + total - 2))
	  return screen
	else
	  -- Case 2: It's on this line. Calculate the X offset of the substring the point bounds.
	  -- Subtract 2 here because both the line break and total are counts, not indices. For example, if 
	  screen.x = screen.x + imgui.CalcTextSize(self.text:sub(self.line_breaks[i], self.line_breaks[i] + total - 2))
	  --screen.x = screen.x + (point * self.advance.x)
	  return screen
	end
  end
end

function TextEditor:mouse_to_point()
  local screen = tdengine.vec2(imgui.GetCursorScreenPos())
  local mouse = tdengine.vec2(imgui.GetMousePos())
  local window_coordinates = mouse:subtract(screen)
  if window_coordinates.y < 0 then return self.point end

  -- Determine which
  local line, offset = self:point_to_line_index()
  local i = 1
  local point = 0
  while true do
	if window_coordinates.y < self.advance.y then break end
	if i == #self.line_breaks then break end
	
	local line_size = self.line_breaks[i + 1] - self.line_breaks[i]
	point = point + line_size
	window_coordinates.y = window_coordinates.y -  self.advance.y
	i = i + 1
  end

  -- Then, it's just how far the point is into the last line
  point = point + math.ceil(window_coordinates.x / self.advance.x)
  return math.min(point, #self.text)
end

function TextEditor:point_to_line_index()
  if self.point == #self.text + 1 then
	local i = #self.line_breaks - 1
	local last_line_size = self:line_size(i)
	return i, last_line_size + 1
  end
  
  local point = self.point
  for i = 1, #self.line_breaks - 1 do
	local line_size = self.line_breaks[i + 1] - self.line_breaks[i]
	if point <= line_size then return i, point end
	point = point - line_size
  end
end

function TextEditor:get_line(i)
  return self.text:sub(self.line_breaks[i], self.line_breaks[i + 1])
end

function TextEditor:line_text_size(i)
  local line_begin = self.line_breaks[i]
  local line_end = self.line_breaks[i + 1] - 1
  return imgui.CalcTextSize(self.text:sub(line_begin, line_end))
end

function TextEditor:line_size(i)
  return self.line_breaks[i + 1] - self.line_breaks[i]
end
