local MainMenu = tdengine.entity('MainMenu')

local state = {
  idle = 'idle',
  choosing_dialogue = 'choosing_dialogue'
}

function MainMenu:init(params)
  self.open_save_layout_modal = false
  self.open_new_dialogue_modal = false
  self.open_save_dialogue_modal = false
  self.state = state.idle

  self.ids = {
	save_layout = '##ded:save_layout',
	save_dialogue = '##ded:save_dialogue',
	new_dialogue = '##ded:new_dialogue'
  }
end

function MainMenu:update(dt)
  if imgui.BeginMainMenuBar() then
	if imgui.BeginMenu('Layout') then
	  if imgui.BeginMenu('Load') then
		local layouts = tdengine.scandir(tdengine.path_constants.fm_layouts)
		for i, layout in pairs(layouts) do
		  if imgui.MenuItem(tdengine.strip_extension(layout)) then
			tdengine.layout(tdengine.strip_extension(layout))
		  end
		end
		imgui.EndMenu() -- Load
	  end

	  if imgui.MenuItem('Save As') then
		self.open_save_layout_modal = true
	  end

	  imgui.EndMenu() -- Layout
	end
	
	if imgui.BeginMenu('Dialogue') then
	  local dialogue_editor = tdengine.find_entity('DialogueEditor')

	  if imgui.MenuItem('New') then
		self.open_new_dialogue_modal = true
	  end

	  if imgui.MenuItem('Load') then
		imgui.SetFileBrowserPwd(tdengine.path_constants.fm_dialogues)
		imgui.OpenFileBrowser()
		self.state = state.choosing_dialogue
	  end

	  if imgui.MenuItem('Run') then
		dialogue_editor:run()
	  end

	  if imgui.MenuItem('Save') then
		dialogue_editor:save(dialogue_editor.loaded)
	  end

	  if imgui.MenuItem('Save As') then
		self.open_save_dialogue_modal = true
	  end


	  imgui.EndMenu() -- Dialogue
	end
	
	imgui.EndMainMenuBar()
  end

  if self.state == state.choosing_dialogue then
	if imgui.IsFileSelected() then
	  local dialogue_editor = tdengine.find_entity('DialogueEditor')
	  dialogue_editor:load(imgui.GetSelectedFile())
	  tdengine.layout('ded')
	  self.state = state.idle
	end
  end

  self:show_modals()
end

function MainMenu:show_modals(dt)
  -- Save layout
  if self.open_save_layout_modal then
	imgui.OpenPopup('Save Layout')
  end
  if imgui.BeginPopupModal('Save Layout') then
	imgui.Text('Name')
	imgui.SameLine()
	imgui.InputText2(self.ids.save_layout)

	if imgui.Button('Save') then
	  tdengine.save_layout(imgui.InputTextGet(self.ids.save_layout))
	  imgui.InputTextSet(self.ids.save_layout, '')
	  imgui.CloseCurrentPopup()
	end
	imgui.SameLine()

	if imgui.Button('Cancel') then
	  imgui.InputTextSet(self.ids.save_layout, '')
	  imgui.CloseCurrentPopup()
	end
	
	imgui.EndPopup()
  end

  -- Save dialogue
  if self.open_save_dialogue_modal then
	imgui.OpenPopup('Save Dialogue')
  end
  if imgui.BeginPopupModal('Save Dialogue') then
	imgui.Text('Name')
	imgui.SameLine()
	imgui.InputText2(self.ids.save_dialogue)

	if imgui.Button('Save') then
	  local dialogue_editor = tdengine.find_entity('DialogueEditor')
	  local name = imgui.InputTextGet(self.ids.save_dialogue)
	  dialogue_editor:save(name)
	  dialogue_editor:load(name) -- So we are editing the fresh copy
	  
	  -- Clean up
	  imgui.InputTextSet(self.ids.save_dialogue, '')
	  imgui.CloseCurrentPopup()
	end
	imgui.SameLine()

	if imgui.Button('Cancel') then
	  imgui.InputTextSet(self.ids.save_dialogue, '')
	  imgui.CloseCurrentPopup()
	end
	
	imgui.EndPopup()
  end

  -- New dialogue
  if self.open_new_dialogue_modal then
	imgui.OpenPopup('New Dialogue')
  end
  if imgui.BeginPopupModal('New Dialogue') then
	imgui.Text('Name')
	imgui.SameLine()
	imgui.InputText2(self.ids.new_dialogue)

	if imgui.Button('Save') then
	  tdengine.layout('ded')
	  
	  local dialogue_editor = tdengine.find_entity('DialogueEditor')
	  local name = imgui.InputTextGet(self.ids.new_dialogue)
	  dialogue_editor:new(name)
	  
	  -- Clean up
	  imgui.InputTextSet(self.ids.new_dialogue, '')
	  imgui.CloseCurrentPopup()
	end
	imgui.SameLine()

	if imgui.Button('Cancel') then
	  imgui.InputTextSet(self.ids.new_dialogue, '')
	  imgui.CloseCurrentPopup()
	end
	
	imgui.EndPopup()
  end
  
  self.open_save_layout_modal   = false
  self.open_new_dialogue_modal  = false
  self.open_save_dialogue_modal = false
end
