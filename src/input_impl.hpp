int init_glfw() {
	auto result = glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
	glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GLFW_TRUE);

	glfwSetErrorCallback(GLFW_Error_Callback);

	g_window = glfwCreateWindow((int)screen_x, (int)screen_y, "firmament", NULL, NULL);
	if (g_window == NULL) {
		tdns_log.write("Failed to create GLFW window");
		glfwTerminate();
		return -1;
	}
	glfwMakeContextCurrent(g_window);

	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
		tdns_log.write("Failed to initialize GLAD");
		return -1;
	}
	
	glfwSetCursorPosCallback(g_window, GLFW_Cursor_Pos_Callback);
	glfwSetMouseButtonCallback(g_window, GLFW_Mouse_Button_Callback);
	glfwSetKeyCallback(g_window, GLFW_Key_Callback);
	glfwSetScrollCallback(g_window, GLFW_Scroll_Callback);
	glfwSetWindowSizeCallback(g_window, GLFW_Window_Size_Callback);
	
	glfwSwapInterval(0);

	return 0;
}

InputManager::InputManager() {
	fill_shift_map();
}

void InputManager::enable_channel(int8 channel) {
	// When we stop feeding to ImGui, we restore the old mask. If we enable a channel now,
	// it must be added to the old mask to persist when Imgui stops.
	if (mask & INPUT_MASK_IMGUI) {
		old_mask |= channel;
	}
		
	mask |= channel;
}
	
void InputManager::disable_channel(int8 channel) {
	if (mask & INPUT_MASK_IMGUI){
		old_mask &= ~channel;
	}
		
	mask &= ~channel;
}

void InputManager::start_imgui() {
	old_mask = mask;
	mask = INPUT_MASK_IMGUI;
}
	
void InputManager::stop_imgui() {
	if (!(mask & INPUT_MASK_IMGUI)) return; 
	mask = old_mask;
}
	
bool InputManager::was_pressed(GLFW_KEY_TYPE id, int channel) {
	if (!(this->mask & channel)) return false;
	return is_down[id] && !was_down[id];
}
	
bool InputManager::was_released(GLFW_KEY_TYPE id, int channel) {
	if (!(this->mask & channel)) return false;
	return !is_down[id] && was_down[id];
}
	
bool InputManager::is_mod_down(GLFW_KEY_TYPE mod_key, int channel) {
	if (!(this->mask & channel)) return false;
		
	bool down = false;
	if (mod_key == GLFW_KEY_CONTROL) {
		down |= is_down[GLFW_KEY_RIGHT_CONTROL];
		down |= is_down[GLFW_KEY_LEFT_CONTROL];
	}
	if (mod_key == GLFW_KEY_SUPER) {
		down |= is_down[GLFW_KEY_LEFT_SUPER];
		down |= is_down[GLFW_KEY_RIGHT_SUPER];
	}
	if (mod_key == GLFW_KEY_SHIFT) {
		down |= is_down[GLFW_KEY_LEFT_SHIFT];
		down |= is_down[GLFW_KEY_RIGHT_SHIFT];
	}
	if (mod_key == GLFW_KEY_ALT) {
		down |= is_down[GLFW_KEY_LEFT_ALT];
		down |= is_down[GLFW_KEY_RIGHT_ALT];
	}

	return down;
}

bool InputManager::chord(GLFW_KEY_TYPE mod_key, GLFW_KEY_TYPE cmd_key, int channel) {
	if (!(this->mask & channel)) return false;
	return is_mod_down(mod_key, channel) && was_pressed(cmd_key, channel);
}

void InputManager::begin_frame() {
	// Fill the input manager's buffers with what GLFW tells us
	glfwPollEvents();

	// Determine whether ImGui is requesting key inputs
	ImGuiIO& imgui = ImGui::GetIO();

	// ImGui always gets mouse input, because how else would it know to request to capture keys?
	imgui.MousePos = ImVec2((float)px_pos.x, (float)px_pos.y);
	imgui.MouseDown[0] = is_down[GLFW_MOUSE_BUTTON_LEFT];
	imgui.MouseDown[1] = is_down[GLFW_MOUSE_BUTTON_RIGHT];

	// If ImGui isn't actively asking for input, don't give it anything
	if (!(imgui.WantCaptureKeyboard || imgui.WantCaptureMouse)) {
		stop_imgui();
		return;
	}	

	// Tell the input manager that only reads to the input buffer from ImGui should go through.
	start_imgui();

	// Fill in the raw ImGui buffer
	for (int key = 0; key < GLFW_KEY_LAST; key++) {
		imgui.KeysDown[key] = is_down[key];
	}
	
	// Fill in the input characters
	// Non-alphas first. 
	for (int key = GLFW_KEY_SPACE; key < GLFW_KEY_A; key++) {
		if (was_pressed(key)) {
			if (is_mod_down(GLFW_KEY_SHIFT)) {
				imgui.AddInputCharacter(shift_map[key]);
			} else {
				imgui.AddInputCharacter(key);
			}
		}
	}

	for (int key = GLFW_KEY_LEFT_BRACKET; key < GLFW_KEY_GRAVE_ACCENT; key++) {
		if (was_pressed(key)) {
			if (is_mod_down(GLFW_KEY_SHIFT)) {
				imgui.AddInputCharacter(shift_map[key]);
			} else {
				imgui.AddInputCharacter(key);
			}
		}
	}
	// Alphas have to be adjusted because GLFW uses the capital ASCII code
	for (int key = GLFW_KEY_A; key <= GLFW_KEY_Z; key++) {
		if (was_pressed(key)) {
			if (is_mod_down(GLFW_KEY_SHIFT)) {
				imgui.AddInputCharacter(key);
			} else {
				imgui.AddInputCharacter(key + 0x20);
			}
		}
	}

	// Add controller keys
	imgui.KeyCtrl = imgui.KeysDown[GLFW_KEY_LEFT_CONTROL] || imgui.KeysDown[GLFW_KEY_RIGHT_CONTROL];
	imgui.KeyShift = imgui.KeysDown[GLFW_KEY_LEFT_SHIFT] || imgui.KeysDown[GLFW_KEY_RIGHT_SHIFT];
	imgui.KeyAlt = imgui.KeysDown[GLFW_KEY_LEFT_ALT] || imgui.KeysDown[GLFW_KEY_RIGHT_ALT];
	imgui.KeySuper = imgui.KeysDown[GLFW_KEY_LEFT_SUPER] || imgui.KeysDown[GLFW_KEY_RIGHT_SUPER];

}

	
void InputManager::end_frame() {
	// If we disabled inputs this frame for ImGui, re-enable and check again next frame
	stop_imgui();

	fox_for(input_id, GLFW_KEY_LAST) {
		was_down[input_id] = is_down[input_id];
	}

	scroll = { 0.f, 0.f };
}
	
void InputManager::fill_shift_map() {
	fox_for(i, 128) {
		shift_map[i] = 0;
	}
		
	shift_map[' ']  =  ' ';
	shift_map['\''] =  '"';
	shift_map[',']  =  '<';
	shift_map['-']  =  '_';
	shift_map['.']  =  '>';
	shift_map['/']  =  '?';

	shift_map['0']  =  ')';
	shift_map['1']  =  '!';
	shift_map['2']  =  '@';
	shift_map['3']  =  '#';
	shift_map['4']  =  '$';
	shift_map['5']  =  '%';
	shift_map['6']  =  '^';
	shift_map['7']  =  '&';
	shift_map['8']  =  '*';
	shift_map['9']  =  '(';

	shift_map[';']  =  ':';
	shift_map['=']  =  '+';
	shift_map['[']  =  '{';
	shift_map['\\'] =  '|';
	shift_map[']']  =  '}';
	shift_map['`']  =  '~';
		
	shift_map['a']  =  'A';
	shift_map['b']  =  'B';
	shift_map['c']  =  'C';
	shift_map['d']  =  'D';
	shift_map['e']  =  'E';
	shift_map['f']  =  'F';
	shift_map['g']  =  'G';
	shift_map['h']  =  'H';
	shift_map['i']  =  'I';
	shift_map['j']  =  'J';
	shift_map['k']  =  'K';
	shift_map['l']  =  'L';
	shift_map['m']  =  'M';
	shift_map['n']  =  'N';
	shift_map['o']  =  'O';
	shift_map['p']  =  'P';
	shift_map['q']  =  'Q';
	shift_map['r']  =  'R';
	shift_map['s']  =  'S';
	shift_map['t']  =  'T';
	shift_map['u']  =  'U';
	shift_map['v']  =  'V';
	shift_map['w']  =  'W';
	shift_map['x']  =  'X';
	shift_map['y']  =  'Y';
	shift_map['z']  =  'Z';
}

InputManager& get_input_manager() {
	static InputManager manager;
	return manager;
}

// GLFW Callbacks
static void GLFW_Cursor_Pos_Callback(GLFWwindow* window, double xpos, double ypos) {
	auto& input_manager = get_input_manager();
	xpos = std::max<double>(xpos, 0); ypos = std::max<double>(ypos, 0);
	input_manager.px_pos = glm::vec2(xpos, screen_y - ypos);
	input_manager.screen_pos = screen_from_px(input_manager.px_pos);
}

void GLFW_Mouse_Button_Callback(GLFWwindow* window, int button, int action, int mods) {
	auto& input_manager = get_input_manager();
	if (button == GLFW_MOUSE_BUTTON_LEFT) {
		if (action == GLFW_PRESS) {
			input_manager.is_down[GLFW_MOUSE_BUTTON_LEFT] = true;
		}
		if (action == GLFW_RELEASE) {
			input_manager.is_down[GLFW_MOUSE_BUTTON_LEFT] = false;
		}
	}
	if (button == GLFW_MOUSE_BUTTON_RIGHT) {
		if (action == GLFW_PRESS) {
			input_manager.is_down[GLFW_MOUSE_BUTTON_RIGHT] = true;
		}
		if (action == GLFW_RELEASE) {
			input_manager.is_down[GLFW_MOUSE_BUTTON_RIGHT] = false;
		}
	}
}

void GLFW_Key_Callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
	auto& manager = get_input_manager();
	
	if (action == GLFW_PRESS) {
		manager.is_down[key] = true;
	}
    if (action == GLFW_RELEASE) {
		manager.is_down[key] = false;
	}
}

void GLFW_Scroll_Callback(GLFWwindow* window, double xoffset, double yoffset) {
	auto& input_manager = get_input_manager();
	
	input_manager.scroll = glm::vec2((float)xoffset, (float)yoffset);
	
	ImGuiIO& io = ImGui::GetIO();
	io.MouseWheelH += (float)xoffset;
	io.MouseWheel += (float)yoffset;
}

void GLFW_Error_Callback(int err, const char* msg) {
	std::cout << err;
	std::cout << msg;
}

void GLFW_Window_Size_Callback(GLFWwindow* window, int width, int height) {
	use_arbitrary_screen_size(height, width);
}


