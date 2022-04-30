local OptionUpdater = tdengine.entity('OptionUpdater')
function OptionUpdater:init(params)
  self.options = {
	scroll_speed    = 0.05,
  	scroll_lerp     = 0.50,
	smooth_scroll   = false,
	mtb_speaker_pad = 0.01,
	game_fontsize   = 48,
	editor_fontsize = 16,
	show_imgui_demo = false,
	show_text_box   = true
  }

  self.last_frame = table.shallow_copy(self.options)
  self.this_frame = table.shallow_copy(self.options)

  self.editor = imgui.extensions.TableEditor(self.this_frame)
end

function OptionUpdater:update(dt)
  imgui.Begin('options')
  self.editor:draw()

  local setopts = {}
  local change = false
  for key, last_value in pairs(self.last_frame) do
	local next_value = self.this_frame[key]
	local equal = false
	equal = equal or type(next_value) == 'number' and double_eq(last_value, next_value)
	equal = equal or (type(next_value) ~= 'number' and last_value == next_value)
	
	if not equal then
	  setopts[key] = next_value
	  self.last_frame[key] = next_value
	  change = true
	end
  end
  if change then tdengine.setopts(setopts) end

  imgui.End()
end
