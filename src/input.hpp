#define INPUT_MASK_NONE   0x0
#define INPUT_MASK_IMGUI  0x1
#define INPUT_MASK_EDITOR 0x2
#define INPUT_MASK_GAME   0x4
#define INPUT_MASK_ALL    0xFF

struct InputManager {
	bool should_update;
	glm::vec2 px_pos;
	glm::vec2 screen_pos;
	glm::vec2 world_pos;
	glm::vec2 scroll;

	int8 mask     = INPUT_MASK_NONE;
	int8 old_mask = INPUT_MASK_NONE;

	bool is_down[GLFW_KEY_LAST];
	bool was_down[GLFW_KEY_LAST];
	char shift_map[128];

	InputManager();

	void enable_channel(int8 channel);
	void disable_channel(int8 channel);
	void start_imgui();
	void stop_imgui();
	bool was_pressed(GLFW_KEY_TYPE id, int channel = INPUT_MASK_ALL);
	bool was_released(GLFW_KEY_TYPE id, int channel = INPUT_MASK_ALL);
	bool is_mod_down(GLFW_KEY_TYPE mod_key, int channel = INPUT_MASK_ALL);
	bool chord(GLFW_KEY_TYPE mod_key, GLFW_KEY_TYPE cmd_key, int channel = INPUT_MASK_ALL);
	void begin_frame();
	void end_frame();	
	void fill_shift_map();};

InputManager& get_input_manager();
int init_glfw();

// GLFW Callbacks
static void GLFW_Cursor_Pos_Callback(GLFWwindow* window, double xpos, double ypos);
void GLFW_Mouse_Button_Callback(GLFWwindow* window, int button, int action, int mods);
void GLFW_Key_Callback(GLFWwindow* window, int key, int scancode, int action, int mods);
void GLFW_Scroll_Callback(GLFWwindow* window, double xoffset, double yoffset);
void GLFW_Error_Callback(int err, const char* msg);
void GLFW_Window_Size_Callback(GLFWwindow* window, int width, int height);
