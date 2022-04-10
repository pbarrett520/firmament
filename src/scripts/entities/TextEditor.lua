local glfw = require('glfw')
local TextEditor = tdengine.entity('TextEditor')
function TextEditor:init(params)
  params = params or {}
  self.text = params.text or ''
  self.point = 0
  self.line_breaks = {}
  
  self.frame = 0
  self.blink_speed = 20
  self.blink_acc = self.blink_speed
  self.blink = true

  self.repeat_delay = .3
  self.repeat_time = {}
	
  self.input = tdengine.create_class('Input')
  self.input:set_channel(tdengine.InputChannel.ImGui)
  self.input:enable()
end

function TextEditor:next_character()
  self.point = self.point + 1
end

function TextEditor:prev_character()
  self.point = self.point - 1
end

function TextEditor:point_to_screen()
  local point = self.point
  local screen = tdengine.vec2(imgui.GetCursorScreenPos())
  local advance = tdengine.vec2(imgui.CalcTextSize(' '), imgui.GetTextLineHeightWithSpacing())
  for i = 1, #self.line_breaks - 1 do
	local line_size = self.line_breaks[i + 1] - self.line_breaks[i]
	if point > line_size then
	  point = point - line_size
	  screen.y = screen.y + advance.y
	else
	  screen.x = screen.x + (point * advance.x * .96)
	  return screen
	end
  end
end

function TextEditor:do_check_repeat(dt, key, f, ...)
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

function TextEditor:update(dt)
  self.frame = self.frame + 1
  self:update_blink()
  
  --self.text = ''; self.point = 0
  self.input:set_channel(tdengine.InputChannel.ImGui)
  imgui.Begin('Text Editor', true)
  
  -- Handle characters, backspaces, key commands, whatever
  if imgui.IsWindowFocused() then
	local queue = imgui.GetInputQueue()
	for i = 1, #queue do
	  self.text = self.text .. queue:at(i)
	  self:next_character()
	end

	self:do_check_repeat(dt, glfw.keys.BACKSPACE, self.do_backspace, self)
  end

  -- Calculate line breaks
  self.line_breaks = { 1 }
  local i = 0
  local point = 0
  local max_length, max_height = imgui.GetWindowContentRegionMax()
  local advance = tdengine.vec2(imgui.CalcTextSize('#'), imgui.GetTextLineHeightWithSpacing())
  for j = 1, #self.text do
	point = point + advance.x

	local cstart = point + advance.x
	local cend = point + (advance.x * 2)
	if (cend > max_length) then
	  table.insert(self.line_breaks, j)
	  point = 0
	end
  end
  table.insert(self.line_breaks, #self.text + 1)

  if self.blink then	
	local tl = self:point_to_screen()
	local dim = tdengine.vec2(2, advance.y)
	local color = imgui.ColorConvertFloat4ToU32(1, 0, 0, .3)
	imgui.AddRectFilled(tl.x, tl.y, tl.x + dim.x, tl.y + dim.y, color)
  end
  
  -- Draw the text
  for i = 1, (#self.line_breaks - 1) do
	local low = self.line_breaks[i]
	local high = self.line_breaks[i + 1] - 1
	imgui.Text(self.text:sub(low, high))
  end
  imgui.End()
end

function TextEditor:update_blink()
  self.blink_acc = self.blink_acc + 1
  if self.blink_acc == self.blink_speed then
	self.blink = not self.blink
	self.blink_acc = 0
  end
end

function TextEditor:do_backspace()
  if self.point == 0 then return end
  local before = self.text:sub(1, self.point - 1)
  local after = self.text:sub(self.point + 1, #self.text)
  self.text = before .. after
  self:prev_character()
end
