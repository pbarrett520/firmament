local Input = tdengine.class('Input')
function Input:init(params)
  params = params or {}
  self.channel = params.channel or tdengine.InputChannel.Editor
end

function Input:was_pressed(key, channel)
  channel = channel or self.channel
  return tdengine.was_pressed(key, channel)
end

function Input:was_released(key, channel)
  channel = channel or self.channel
  return tdengine.was_released(key, channel)
end

function Input:is_down(key, channel)
  channel = channel or self.channel
  return tdengine.is_down(key, channel)
end

function Input:chord(mod, key, channel)
  channel = channel or self.channel
  return tdengine.was_chord_pressed(mod, key, channel)
end

function Input:set_channel(channel)
  self.channel = channel
end

function Input:enable()
  tdengine.enable_input_channel(self.channel)
end

function Input:disable()
  tdengine.disable_input_channel(self.channel)
end
