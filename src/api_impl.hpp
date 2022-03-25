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

void API::screen(const char* dimension) {
	if (!strcmp(dimension, "640")) use_640_360();
	else if (!strcmp(dimension, "720")) use_720p();
	else if (!strcmp(dimension, "1080")) use_1080p();
	else if (!strcmp(dimension, "1440")) use_1440p();
}

void API::submit_text(sol::table request) {
	auto& render_engine = get_render_engine();

	TextRenderInfo info;
	std::string text_copy = request["text"];
	fm_assert(text_copy.size() < MAX_TEXT_LEN);
	strncpy(info.text, text_copy.c_str(), MAX_TEXT_LEN);

	// Calculate line breaks based on size of text box
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
	
	arr_for(text, c) {
		if (*c == 0) break;

		GlyphInfo* glyph = font->glyphs[*c];
		point.x += glyph->advance.x;

		if (point.x >= max_x) {
			arr_push(&lbreaks, arr_index(&text, c));
			point.x = box->pos.x + box->pad.x;
			point.y -= font->descender;
		}
	}
	
	
	// No effect? Just give it to the renderer
	if (request["effect"] == sol::lua_nil) {
		arr_push(&text_buffer, info);
		return;
	};

	// If there is an effect, figure out what type it is and parse it.
	TextEffect effect;
	effect.type = static_cast<TextEffectType>(request["effect"]["type"]);
	if (effect.type == TextEffectType::OSCILLATE) {
		OscillateEffect* effect_data = &effect.data.oscillate;
		effect_data->amplitude = request["effect"]["amplitude"];
		effect_data->frequency = request["effect"]["frequency"];
	}
	else if (effect.type == TextEffectType::RAINBOW) {
		RainbowEffect* effect_data = &effect.data.rainbow;
		effect_data->frequency = request["effect"]["frequency"];
	}

	// Then, add it to our buffer of effects and give the info the pointer to the stored effect
	info.effects = arr_slice(&effect_buffer, effect_buffer.size, 1);
	arr_push(&effect_buffer, effect);

	arr_push(&text_buffer, info);
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
	state["tdengine"]["submit_dbg_geometry"]       = &API::submit_dbg_geometry;

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
}
