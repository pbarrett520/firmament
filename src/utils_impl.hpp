void init_imgui() {
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGui_ImplGlfwGL3_Init(g_window, false);
	
	auto& imgui = ImGui::GetIO();
	imgui.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
	ImGui::StyleColorsDark();

	auto imgui_font = imgui.Fonts->AddFontFromFileTTF(fm_ed_font_path, (float)fm_ed_font_size);

	imgui.IniFilename = nullptr;

	// Engine will pick this up on the first tick (before ImGui renders, so no flickering)
	API::use_layout("default");
}

void load_imgui_layout() {
	if (!strlen(layout_to_load)) return;

	ImGui::LoadIniSettingsFromDisk(layout_to_load);
	if (set_to_selected > 0) ImGuiWrapper::MakeTabVisible(set_to_selected);
														  
	tdns_log.write(Log_Flags::File,
				   "load imgui layout: path = %s, id = %u",
				   layout_to_load,
				   set_to_selected);

	memset(layout_to_load, 0, MAX_PATH_LEN);
}
