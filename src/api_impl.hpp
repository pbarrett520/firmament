void API::enable_input_channel(int channel) {
	auto& input_manager = get_input_manager();
	input_manager.enable_channel(channel);
}

void API::disable_input_channel(int channel) {
	auto& input_manager = get_input_manager();
	input_manager.disable_channel(channel);
}

bool API::is_down(GLFW_KEY_TYPE id, int mask) {
	auto& manager = get_input_manager();
	if (!(manager.mask & mask)) return false;
	return manager.is_down[id];
}

bool API::was_pressed(GLFW_KEY_TYPE id, int mask) {
	auto& manager = get_input_manager();
	return manager.was_pressed(id, mask);
}

bool API::was_released(GLFW_KEY_TYPE id, int mask) {
	auto& manager = get_input_manager();
	return manager.was_released(id, mask);
}

bool API::was_chord_pressed(GLFW_KEY_TYPE mod_key, GLFW_KEY_TYPE cmd_key, int mask) {
	auto& manager = get_input_manager();
	return manager.chord(mod_key, cmd_key, mask);
}

sol::object API::cursor() {
	auto& manager = get_input_manager();
	
	auto out = Lua.state.create_table();
	out["x"] = manager.screen_pos.x;
	out["y"] = manager.screen_pos.y;
	return out;
}

sol::object API::screen_dimensions() {
	auto out = Lua.state.create_table();
	out["x"] = screen_x;
	out["y"] = screen_y;
	return out;
}

void API::toggle_console() {
	show_console = !show_console;
}

void API::use_layout(const char* name) {
	fm_layout(name, layout_to_load, MAX_PATH_LEN);
}

void API::save_layout(const char* name) {
	// @firmament arena allocator
	char* path = (char*)calloc(MAX_PATH_LEN, sizeof(char));
	fm_layout(name, path, MAX_PATH_LEN);
	
	ImGui::SaveIniSettingsToDisk(path);
	tdns_log.write(Log_Flags::File, "saved imgui layout: path = %s", path);
}

void API::save_layout_by_path(const char* path) {
	ImGui::SaveIniSettingsToDisk(path);
	tdns_log.write(Log_Flags::File, "saved imgui layout: path = %s", path);
}

void API::screen(const char* dimension) {
	if (!strcmp(dimension, "640")) use_640_360();
	else if (!strcmp(dimension, "720")) use_720p();
	else if (!strcmp(dimension, "1080")) use_1080p();
	else if (!strcmp(dimension, "1440")) use_1440p();
}

void API::submit_choice(sol::table request) {
	ChoiceBox* cbx = &choice_box;
	ChoiceInfo* choice = arr_push(&choice_buffer);
	
	std::string text_copy = request["text"];
	fm_assert(text_copy.size() < MAX_CHOICE_LEN);
	strncpy(choice->text, text_copy.c_str(), MAX_CHOICE_LEN);
}

void API::set_hovered_choice(int32 index) {
	ChoiceBox* cbx = &choice_box;
	cbx->hovered = index;
}

void API::clear_choices() {
	cbx_clear(&choice_box);
}

void API::submit_text(sol::table request) {
	auto& render_engine = get_render_engine();

	TextRenderInfo info;

	// Copy the text
	std::string text_copy = request["text"];
	if (text_copy.size() >= MAX_TEXT_LEN) {
		tdns_log.write("total text size too long -- ctrl+f MAX_TEXT_LEN, double it, rebuild, text = %s", text_copy.c_str());
		return;
	}

	strncpy(info.text, text_copy.c_str(), MAX_TEXT_LEN);

	// Fill out info about the speaker
	std::string speaker_name = request["character"]["display_name"].get_or(fallbacks::text_speaker);
	strncpy(info.speaker, speaker_name.c_str(), MAX_SPEAKER_LEN);
	
	info.speaker_len = speaker_name.size();

	sol::optional<sol::table> speaker_color = request["character"]["color"];
	info.speaker_color = (speaker_color == sol::nullopt) ?
		info.speaker_color = fallbacks::text_color : 
		info.speaker_color = decode_color32(*speaker_color);
	
	// Calculate line breaks based on size of text box
	ArrayView<char> speaker = arr_view(info.speaker, MAX_SPEAKER_LEN);
	ArrayView<char> text = arr_view(info.text, MAX_TEXT_LEN);
	FontInfo* font = font_infos[0];
	MainTextBox* box = &main_box;
	Vector2 point = {
		box->pos.x + box->pad.x,
		box->pos.y - box->dim.y + box->pad.y - font->descender
	};
	float32 max_x =  box->pos.x + box->dim.x - box->pad.x;
	
	Array<int32> lbreaks;
	arr_stack(&lbreaks, &info.lbreaks[0], MAX_LINE_BREAKS);
	arr_push(&lbreaks, 0); // See definition of line breaks in TextRenderInfo to understand why we always have 0

	// Advance the point by whatever the speaker's name is. I like to keep the speaker's name separate to keep
	// the data structured
	arr_for(speaker, c) {
		if (*c == 0) break;
		
		GlyphInfo* glyph = font->glyphs[*c];
		point.x += glyph->advance.x;
	}
    point.x += font->glyphs[':']->advance.x;
    point.x += font->glyphs[' ']->advance.x;

	// Advance point for text, when it spills over move to the next line and mark a line break
	arr_for(text, c) {
		if (*c == 0) break;

		GlyphInfo* glyph = font->glyphs[*c];
		point.x += glyph->advance.x;

		if (point.x >= max_x) {
			arr_push(&lbreaks, arr_indexof(&text, c));
			point.x = box->pos.x + box->pad.x;
			point.y -= font->descender;
		}
	}

	arr_push(&lbreaks, text.size);
	info.count_lb = lbreaks.size;
	
	
	// No effect? Just give it to the renderer
	if (request["effects"] == sol::lua_nil) {
		arr_push(&text_buffer, info);
		return;
	};

	// If there are effects, iterate through them and parse params into a struct
	sol::table effects = request["effects"];
	int32 count_effects = effects.size();

	// Do this before we actually push effects to the buffer to avoid weird pointer math
	info.effects = arr_slice(&effect_buffer, effect_buffer.size, count_effects);

	for (int i = 1; i <= count_effects; i++) {
		sol::table data = effects[i];
		
		TextEffect effect;
		effect.type = static_cast<TextEffectType>(data["type"]);
		effect.first = data["first"].get_or(0);
		effect.last   = data["last"].get_or(0);
		
		// Type specific data
		if (effect.type == TextEffectType::OSCILLATE) {
			effect.data.oscillate.amplitude = data["amplitude"];
			effect.data.oscillate.frequency = data["frequency"];
			effect.data.oscillate.rnd = rand_float(3);
		}
		else if (effect.type == TextEffectType::RAINBOW) {
			effect.data.rainbow.frequency = data["frequency"];
		}
		else if (effect.type == TextEffectType::HAZY_WAKE) {
		}
		
		arr_push(&effect_buffer, effect);
	}

	arr_push(&text_buffer, info);
}

void API::clear_mtb() {
	arr_clear(&text_buffer);
	arr_clear(&effect_buffer);

	
}


void API::submit_dbg_geometry(sol::table request) {
	auto& render_engine = get_render_engine();

	DbgRenderRequest rq;

	// Request type specific fields
	rq.type = static_cast<DbgRenderType>(request["type"]);
	if (rq.type == DbgRenderType::RECT) {
		rq.pos = {
			(float32)request["pos"]["x"],
			(float32)request["pos"]["y"]
		};

		if (request["color"] != sol::lua_nil) {
			rq.color = {
				(float32)request["color"]["r"],
				(float32)request["color"]["g"],
				(float32)request["color"]["b"],
				(float32)request["color"]["a"]
			};
		}
		
		DbgRenderRect* rect = &rq.data.rect;
		rect->sx = (float32)request["size"]["x"];
		rect->sy = (float32)request["size"]["y"];
	}
	else if (rq.type == DbgRenderType::TEXT_BOX) {
		DbgRenderTextBox* tbox = &rq.data.tbox;
		if (request["main"])   tbox->render_main = true;
		if (request["choice"]) tbox->render_choice = true;
	}
	
	arr_push(&dbg_rq_buffer, rq);
}


void API::log(const char* fmt) {
	tdns_log.write(Log_Flags::Default, fmt);
}

void API::log_to(const char* message, uint8_t flags) {
	tdns_log.write(flags, message);
}

void API::use_step_mode() {
	step_mode = true;
	show_console = false;
}

void API::pause_updates() {
	are_updates_paused = true;
}

void API::resume_updates() {
	are_updates_paused = false;
}

void API::set_imgui_demo(bool show) {
	show_imgui_demo = show;
}

void API::setopts(sol::table opts) {
	if (opts["scroll_speed"] != sol::lua_nil) {
		options::scroll_speed = (float32)opts["scroll_speed"];
	}
	if (opts["scroll_lerp"] != sol::lua_nil) {
		options::scroll_lerp = (float32)opts["scroll_lerp"];
	}
	if (opts["smooth_scroll"] != sol::lua_nil) {
		options::smooth_scroll = opts["scroll_lerp"];
	}
	if (opts["mtb_speaker_pad"] != sol::lua_nil) {
		options::mtb_speaker_pad = opts["mtb_speaker_pad"];
	}
	if (opts["game_fontsize"] != sol::lua_nil) {
		options::game_fontsize = opts["game_fontsize"];
		init_fonts();
	}
	if (opts["show_imgui_demo"] != sol::lua_nil) {
		options::show_imgui_demo = opts["show_imgui_demo"];
	}

}

void register_lua_api() {
	auto& state = Lua.state;
	
	using namespace API;
    state["tdengine"]                              = state.create_table();
	state["tdengine"]["enable_input_channel"]      = &enable_input_channel;
	state["tdengine"]["disable_input_channel"]     = &disable_input_channel;
	state["tdengine"]["is_down"]                   = &is_down;
	state["tdengine"]["was_pressed"]               = &was_pressed;
	state["tdengine"]["was_released"]              = &was_pressed;
	state["tdengine"]["was_chord_pressed"]         = &was_chord_pressed;
	state["tdengine"]["cursor"]                    = &cursor;
	state["tdengine"]["save_layout"]               = &save_layout;
	state["tdengine"]["save_layout_by_path"]       = &save_layout_by_path;
	state["tdengine"]["use_layout"]                = &use_layout;
	state["tdengine"]["frame_time"]                = seconds_per_update;
	state["tdengine"]["screen_dimensions"]         = &screen_dimensions;
	state["tdengine"]["screen"]                    = &screen;
	state["tdengine"]["step_mode"]                 = &use_step_mode;
	state["tdengine"]["log"]                       = &API::log;
	state["tdengine"]["log_to"]                    = &API::log_to;
	state["tdengine"]["toggle_console"]            = &toggle_console;
	state["tdengine"]["pause_updates"]             = &API::pause_updates;
	state["tdengine"]["resume_updates"]            = &resume_updates;
	state["tdengine"]["set_imgui_demo"]            = &set_imgui_demo;
	state["tdengine"]["submit_text"]               = &API::submit_text;
	state["tdengine"]["clear_mtb"]                 = &API::clear_mtb;
	state["tdengine"]["submit_choice"]             = &API::submit_choice;
	state["tdengine"]["set_hovered_choice"]        = &API::set_hovered_choice;
	state["tdengine"]["clear_choices"]             = &API::clear_choices;
	state["tdengine"]["submit_dbg_geometry"]       = &API::submit_dbg_geometry;
	state["tdengine"]["setopts"]                   = &API::setopts;

	state["tdengine"]["log_flags"]= state.create_table();	
	state["tdengine"]["log_flags"]["console"] = Log_Flags::Console;	
	state["tdengine"]["log_flags"]["file"] = Log_Flags::File;	
	state["tdengine"]["log_flags"]["default"] = Log_Flags::Default;	

	state["tdengine"]["InputChannel"] = state.create_table();
	state["tdengine"]["InputChannel"]["None"] = INPUT_MASK_NONE;
	state["tdengine"]["InputChannel"]["ImGui"] = INPUT_MASK_IMGUI;
	state["tdengine"]["InputChannel"]["Editor"] = INPUT_MASK_EDITOR;
	state["tdengine"]["InputChannel"]["Game"] = INPUT_MASK_GAME;
	state["tdengine"]["InputChannel"]["All"] = INPUT_MASK_ALL;

	state["tdengine"]["effects"] = state.create_table();
	state["tdengine"]["effects"]["none"] = TextEffectType::NONE;
	state["tdengine"]["effects"]["oscillate"] = TextEffectType::OSCILLATE;
	state["tdengine"]["effects"]["rainbow"] = TextEffectType::RAINBOW;

	state["tdengine"]["effect_names"] = state.create_table();
	auto effects = arr_view(effect_names);
	arr_for(effects, effect) {
		int32 i = arr_indexof(&effects, effect);
		state["tdengine"]["effect_names"][i] = effect_names[i];
	}

	// ImGui
	lua_newtable(Lua.raw_state);
	luaL_setfuncs(Lua.raw_state, imguilib, 0);
	PushImguiEnums(Lua.raw_state, "constant");
	lua_setglobal(Lua.raw_state, "imgui");

	//  My ImGui wrappers for things that do not work with the binding generator
	Lua.state["imgui"]["Text"]                 = &ImGuiExt::Text;
	Lua.state["imgui"]["SetNextWindowSize"]    = &ImGuiExt::SetNextWindowSize;
	Lua.state["imgui"]["IsItemHovered"]        = &ImGuiExt::IsItemHovered;
	Lua.state["imgui"]["InputText"]            = &ImGuiExt::InputText;
	Lua.state["imgui"]["InputTextMultiline"]   = &ImGuiExt::InputTextMultiline;
	Lua.state["imgui"]["InputTextClear"]       = &ImGuiExt::InputTextClear;
	Lua.state["imgui"]["InputTextContents"]    = &ImGuiExt::InputTextContents;
	Lua.state["imgui"]["InputTextSetContents"] = &ImGuiExt::InputTextSetContents;
	Lua.state["imgui"]["InputText2"]           = &ImGuiExt::InputText2;
	Lua.state["imgui"]["InputTextGet"]         = &ImGuiExt::InputTextGet;
	Lua.state["imgui"]["InputTextSet"]         = &ImGuiExt::InputTextSet;
	Lua.state["imgui"]["InputFloat"]           = &ImGuiExt::InputFloat;
	Lua.state["imgui"]["InputFloatGet"]        = &ImGuiExt::InputFloatGet;
	Lua.state["imgui"]["InputFloatSet"]        = &ImGuiExt::InputFloatSet;
	Lua.state["imgui"]["Checkbox"]             = &ImGuiExt::Checkbox;
	Lua.state["imgui"]["CheckboxGet"]          = &ImGuiExt::CheckboxGet;
	Lua.state["imgui"]["CheckboxSet"]          = &ImGuiExt::CheckboxSet;
	Lua.state["imgui"]["MakeTabVisible"]       = &ImGuiExt::MakeTabVisible;
	Lua.state["imgui"]["GetSelectedTabId"]     = &ImGuiExt::GetSelectedTabId;
	Lua.state["imgui"]["GetTabId"]             = &ImGuiExt::GetTabId;
	Lua.state["imgui"]["IsWindowFocused"]      = &ImGuiExt::IsWindowFocused;
	Lua.state["imgui"]["GetInputQueue"]        = &ImGuiExt::GetInputQueue;
	Lua.state["imgui"]["AddRectFilled"]        = &ImGuiExt::AddRectFilled;
	Lua.state["imgui"]["OpenFileBrowser"]      = &ImGuiExt::OpenFileBrowser;
	Lua.state["imgui"]["CloseFileBrowser"]     = &ImGuiExt::CloseFileBrowser;
	Lua.state["imgui"]["IsFileSelected"]       = &ImGuiExt::IsFileSelected;
	Lua.state["imgui"]["GetSelectedFile"]      = &ImGuiExt::GetSelectedFile;
	Lua.state["imgui"]["SetFileBrowserPwd"]    = &ImGuiExt::SetFileBrowserPwd;

	sol::usertype<ImGuiExt::TextFilter> filter_type = Lua.state.new_usertype<ImGuiExt::TextFilter>("TextFilter");
	filter_type["Draw"]      = &ImGuiExt::TextFilter::Draw;
	filter_type["PassFilter"] = &ImGuiExt::TextFilter::PassFilter;
	Lua.state["imgui"]["TextFilter"] = filter_type;

	Lua.state["imgui"]["End"] = &ImGuiExt::EndAndRecover;
}
