namespace API {
// Input
void        enable_input_channel(int channel);
void        disable_input_channel(int channel);
bool        was_pressed(key_t id, int mask = INPUT_MASK_NONE);
bool        was_released(key_t id, int mask = INPUT_MASK_NONE);
bool        is_down(key_t id, int mask = INPUT_MASK_NONE);
bool        was_chord_pressed(key_t mod, key_t cmd, int mask = INPUT_MASK_NONE);
	
// Draw
void        draw_text(std::string text, float x, float y, int flags);

// Editor
void        toggle_console();
void        use_layout(const char* name);
void        save_layout(const char* name);
void        screen(const char* dimension);
void        use_step_mode();
void        pause_updates();
void        resume_updates();
void        set_imgui_demo(bool show);

// Logging
void        log(const char* message);
void        log_to(const char* message, uint8_t flags);

// Fonts
int         font_advance(std::string font, char c);
sol::object font_info(std::string font);

// Utility
sol::object screen_dimensions();
sol::object cursor();
sol::object camera();
}

void register_lua_api();
