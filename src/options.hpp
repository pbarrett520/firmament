#define _fm_gm_font "apple_kid"
const char* fm_gm_font = _fm_gm_font;

#define _fm_ed_font "inconsolata"
const char* fm_ed_font = _fm_ed_font;

bool debug_show_aabb = false;
bool are_updates_paused = false;
bool print_framerate = false;
bool show_imgui_demo = false;
bool show_console = false;
bool send_kill_signal = false;
bool step_mode = false;

namespace options {
	float32 scroll_speed      = 0.050f;
	float32 scroll_lerp       = 0.500f;
	bool    smooth_scroll     = false;
	float32 mtb_speaker_pad   = 0.010f;
	int32   game_fontsize     = 32;
	int32   editor_fontsize   = 16;
	bool    show_imgui_demo   = false;
};


