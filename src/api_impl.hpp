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

sol::object API::camera() {
	auto& renderer = get_render_engine();
	
	auto out = Lua.state.create_table();
	out["x"] = renderer.camera.x;
	out["y"] = renderer.camera.y;
	return out;
}

void API::toggle_console() {
	show_console = !show_console;
}

void API::use_layout(const char* name) {
	fm_layout(name, layout_to_load, LAYOUT_MAXPATH);
}

void API::save_layout(const char* name) {
	// @firmament arena allocator
	char* path = (char*)calloc(LAYOUT_MAXPATH, sizeof(char));
	fm_layout(name, path, LAYOUT_MAXPATH);
	
	ImGui::SaveIniSettingsToDisk(path);
	tdns_log.write(Log_Flags::File, "saved imgui layout: path = %s", path);
}

void API::draw_text(std::string text, float x, float y, int flags) {
	glm::vec2 point(x, y);
	draw_text(text, point, static_cast<Text_Flags>(flags));
}

void API::screen(const char* dimension) {
	if (!strcmp(dimension, "640")) use_640_360();
	else if (!strcmp(dimension, "720")) use_720p();
	else if (!strcmp(dimension, "1080")) use_1080p();
	else if (!strcmp(dimension, "1440")) use_1440p();
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

int API::font_advance(std::string font_name, char c) {
	auto& font = g_fonts[font_name];
	return font.advance(c);
}

sol::object API::font_info(std::string font_name) {
	auto& font = g_fonts[font_name];
	
	auto info = Lua.state.create_table();
	info["largest"] = Lua.state.create_table();
	info["largest"]["x"] = font.px_largest.x;
	info["largest"]["y"] = font.px_largest.y;

	return info;
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
	state["tdengine"]["camera"]                    = &camera;
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
	state["tdengine"]["font_advance"]              = &font_advance;
	state["tdengine"]["font_info"]                 = &font_info;

	state["tdengine"]["draw_text"]                = &API::draw_text;

	state["tdengine"]["flags"] = state.create_table();
	state["tdengine"]["text_flags"] = state.create_table();
	state["tdengine"]["text_flags"]["none"] = Text_Flags::None;
	state["tdengine"]["text_flags"]["highlighted"] = Text_Flags::Highlighted;

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
