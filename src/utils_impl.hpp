void init_imgui() {
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGui_ImplGlfwGL3_Init(g_window, false);
	
	auto& imgui = ImGui::GetIO();
	imgui.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
	ImGui::StyleColorsDark();

	auto imgui_font = imgui.Fonts->AddFontFromFileTTF(fm_ed_font_path, (float)options::editor_fontsize);

	imgui.IniFilename = nullptr;

	// Engine will pick this up on the first tick (before ImGui renders, so no flickering)
	API::use_layout("default");
}

void load_imgui_layout() {
	if (!strlen(layout_to_load)) return;

	ImGui::LoadIniSettingsFromDisk(layout_to_load);
	if (last_selected_tab > 0) ImGuiExt::MakeTabVisible(last_selected_tab);
														  
	tdns_log.write(Log_Flags::File,
				   "load imgui layout: path = %s, id = %u",
				   layout_to_load,
				   last_selected_tab);

	memset(layout_to_load, 0, MAX_PATH_LEN);
}


InputTextInfo* intext_add(const char* label) {
	size_t hash = hash_label(label);
	arr_for(intext_infos, info) {
		if (info->hash == hash) return info;
	}
	InputTextInfo* info = arr_push(&intext_infos);
	info->hash = hash;
	return info;
}
InputTextInfo* intext_get(const char* label) {
	size_t hash = hash_label(label);
	arr_for(intext_infos, info) {
		if (info->hash == hash) return info;
	}
	return nullptr;
}
void intext_clear(const char* label) {
	size_t hash = hash_label(label);
	arr_for(intext_infos, info) {
		if (info->hash == hash) {
			memset(info->data, 0, INPUT_TEXT_SIZE);
			return;
		}
	}
}

InputFloatInfo* inflt_add(const char* label) {
	size_t hash = hash_label(label);
	arr_for(inflt_infos, info) {
		if (info->hash == hash) return info;
	}
	InputFloatInfo* info = arr_push(&inflt_infos);
	info->hash = hash;
	return info;
}
InputFloatInfo* inflt_get(const char* label) {
	size_t hash = hash_label(label);
	arr_for(inflt_infos, info) {
		if (info->hash == hash) return info;
	}
	return nullptr;
}
void inflt_clear(const char* label) {
	size_t hash = hash_label(label);
	arr_for(inflt_infos, info) {
		if (info->hash == hash) {
			info->data = 0;
			return;
		}
	}
}

InputBoolInfo* inbool_add(const char* label) {
	size_t hash = hash_label(label);
	arr_for(inbool_infos, info) {
		if (info->hash == hash) return info;
	}
	InputBoolInfo* info = arr_push(&inbool_infos);
	info->hash = hash;
	return info;
}
InputBoolInfo* inbool_get(const char* label) {
	size_t hash = hash_label(label);
	arr_for(inbool_infos, info) {
		if (info->hash == hash) return info;
	}
	return nullptr;
}
void inbool_clear(const char* label) {
	size_t hash = hash_label(label);
	arr_for(inbool_infos, info) {
		if (info->hash == hash) {
			info->data = 0;
			return;
		}
	}
}

