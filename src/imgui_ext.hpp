namespace ImGuiExt {
	void SetNextWindowSize(float x, float y) {
		ImGui::SetNextWindowSize(ImVec2(x, y), ImGuiCond_FirstUseEver);
	}

	void Text(const char* text) {
		ImGui::Text(text);
	}

	bool IsItemHovered() {
		return ImGui::IsItemHovered();
	}

	struct TextFilter {
		ImGuiTextFilter filter;

		TextFilter() : filter("") {}
		bool Draw(const char* label) { return filter.Draw(label); }
		bool PassFilter(const char* text) { return filter.PassFilter(text); }
	};

	bool InputTextMultiline(const char* label, int buf_size, float sx, float sy) {
		add_input_text_buffer(label, buf_size);
		InputTextBuffer* buffer = get_input_text_buffer(label);

		ImVec2 size(sx, sy);
		return ImGui::InputTextMultiline(label, buffer->data, buffer->size, size);
	}

	// Stateful InputText, because I don't know how else to do this from Lua
	bool InputText(const char* label) {
		add_input_text_buffer(label, 1024);
		InputTextBuffer* buffer = get_input_text_buffer(label);
		return ImGui::InputText(label, buffer->data, buffer->size, ImGuiInputTextFlags_EnterReturnsTrue);
	}

	const char* InputTextContents(const char* label) {
		InputTextBuffer* buffer = get_input_text_buffer(label);
		if (!buffer) {
			return "You called InputTextContents, but passed an unknown label.";
		}
		return buffer->data;
	}

	void InputTextClear(const char* label) {
		clear_input_text_buffer(label);
	}

	void InputTextSetContents(const char* label, const char* contents) {
		InputTextBuffer* buffer = get_input_text_buffer(label);
		if (!buffer) {
			tdns_log.write("@InputTextSetContents_unknown_label");
			tdns_log.write(label);
			add_input_text_buffer(label, 1024);
			buffer = get_input_text_buffer(label);
		}

		strncpy(buffer->data, contents, buffer->size);
	}

	bool InputText2(const char* label) {
		auto info = intext_add(label);
		return ImGui::InputText(label, info->data, INPUT_TEXT_SIZE, ImGuiInputTextFlags_EnterReturnsTrue);
	}
	const char* InputTextGet(const char* label) {
		auto info = intext_get(label);
		if (!info) { tdns_log.write("tried to get bad input text label, label = %s", label); return "bad input text label"; }
		
		return &info->data[0];
	}
	void InputTextSet(const char* label, const char* data) {
		auto info = intext_get(label);
		
		if (!data) return;
		if (!info) { tdns_log.write("tried to set bad input text label, label = %s", label); return; }
		
		size_t len = strlen(data);
		if (len >= INPUT_TEXT_SIZE) { tdns_log.write("inputtextset input too large, label = %s", label); }

		strncpy(info->data, data, INPUT_TEXT_SIZE);
	}

	
	bool InputFloat(const char* label) {
		auto info = inflt_add(label);
		return ImGui::InputFloat(label, &info->data, 0.f, 0.f, "%.3f", ImGuiInputTextFlags_EnterReturnsTrue);
	}
	float32 InputFloatGet(const char* label) {
		auto info = inflt_get(label);
		if (!info) {
			tdns_log.write("tried to get bad input float label, label = %s", label);
			return 0.f;
		}
		return info->data;
	}
	void InputFloatSet(const char* label, float32 f) {
		auto info = inflt_get(label);
		if (!info) {
			tdns_log.write("tried to set bad input float label, label = %s", label);
			return;
		}
		info->data = f;
	}

	bool Checkbox(const char* label) {
		auto info = inbool_add(label);
		return ImGui::Checkbox(label, &info->data);
	}
	bool CheckboxGet(const char* label) {
		auto info = inbool_get(label);
		if (!info) {
			tdns_log.write("tried to get bad checkbox label, label = %s", label);
			return false;
		}
		return info->data;
	}
	void CheckboxSet(const char* label, bool b) {
		auto info = inbool_get(label);
		if (!info) {
			tdns_log.write("tried to set bad checkbox label, label = %s", label);
			return;
		}
		info->data = b;
	}

	void EndAndRecover() {
		ImGui::ErrorCheckEndFrameRecover(nullptr, nullptr);		
	}

	void MakeTabVisible(ImGuiID id) {
		ImGuiWindow* window = ImGui::FindWindowByName("engine");
		if (window == NULL || window->DockNode == NULL || window->DockNode->TabBar == NULL)
			return;
		window->DockNode->LastFocusedNodeId = id;
		window->DockNode->SelectedTabId = id;
		window->DockNode->TabBar->SelectedTabId = id;
		window->DockNode->TabBar->VisibleTabId = id;
		window->DockNode->TabBar->NextSelectedTabId = id;
	}

	ImGuiID GetSelectedTabId() {
		ImGuiWindow* window = ImGui::FindWindowByName("engine");
		if (window == NULL || window->DockNode == NULL || window->DockNode->TabBar == NULL)
			return 0;
		return window->DockNode->TabBar->SelectedTabId;
	}


	ImGuiID GetTabId(const char* name) {
		ImGuiWindow* window = ImGui::FindWindowByName("engine");
		return window->GetID(name);
	}

	bool IsWindowFocused() {
		return ImGui::IsWindowFocused();
	}

	// @stl
	std::vector<char> GetInputQueue() {
		std::vector<char> queue;
		for (int i = 0; i < ImGui::GetIO().InputQueueCharacters.Size; i++) {
			auto c = ImGui::GetIO().InputQueueCharacters[i];
			if (c != 0 && (c == '\n' || c >= 32)) queue.push_back(c);
		}
		return queue;
	}

	void AddRectFilled(float32 xstart, float32 ystart, float32 xend, float32 yend, uint32 color) {
		auto draw_list = ImGui::GetWindowDrawList();
		draw_list->AddRectFilled({ xstart, ystart }, {xend, yend }, color);
	}

	ImGui::FileBrowser im_file_browser;
	bool open_file_browser;
	bool close_file_browser;
	
	void OpenFileBrowser() {
		open_file_browser = true;
	}
	
	void CloseFileBrowser() {
		close_file_browser = true;
	}

	void DoOpenFileBrowser() {
		im_file_browser.Open();
		open_file_browser = false;
	}

	void DoCloseFileBrowser() {
		im_file_browser.Close();
		close_file_browser = false;
	}

	void UpdateFileBrowser() {
		if (open_file_browser) DoOpenFileBrowser();
		if (close_file_browser) DoCloseFileBrowser();
		im_file_browser.Display();
	}

	bool IsFileSelected() {
		return im_file_browser.HasSelected();
	}
	
	std::string GetSelectedFile() {
		std::string selected = im_file_browser.GetSelected().string();
		im_file_browser.ClearSelected();
		return selected;
	}

	void SetFileBrowserPwd(const char* cwd) {
		im_file_browser.SetPwd(cwd);
	}

	
}

