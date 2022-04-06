function tdengine.paths.dialogue(name)
  return string.format(tdengine.path_constants.fm_dialogue, name)
end

function tdengine.paths.dialogue_layout(name)
  return string.format(tdengine.path_constants.fm_dlglayout, name)
end

function tdengine.paths.layout(name)
  return string.format(tdengine.path_constants.fm_layout, name)
end

function tdengine.paths.state(name)
  name = name or 'default'
  return string.format(tdengine.path_constants.fm_state, name)
end
