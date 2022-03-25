namespace API {
// Input
void        enable_input_channel(int channel);
void        disable_input_channel(int channel);
bool        was_pressed(key_t id, int mask = INPUT_MASK_NONE);
bool        was_released(key_t id, int mask = INPUT_MASK_NONE);
bool        is_down(key_t id, int mask = INPUT_MASK_NONE);
bool        was_chord_pressed(key_t mod, key_t cmd, int mask = INPUT_MASK_NONE);
	
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

// Rendering
void        submit_text(sol::table request);
void        submit_dbg_geometry(sol::table request);

// Utility
sol::object screen_dimensions();
sol::object cursor();
}

void register_lua_api();
