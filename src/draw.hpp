struct Camera {
	float x;
	float y;
};

enum class Text_Flags : int {
	None        = 0,
	Highlighted = 1 << 0
};
ENABLE_ENUM_FLAG(Text_Flags)

struct TextRenderInfo {
	std::string text;
	glm::vec2 point;
	Text_Flags flags;
};

struct RenderEngine {
	std::vector<std::function<void()>> primitives;
	std::vector<TextRenderInfo> text_infos;
	Camera camera;

	uint frame_buffer;
	uint color_buffer;
	
	void init();
	void remove_entity(int entity);
	void render(float dt);
	void render_text(float dt);
	Camera& get_camera();
};

RenderEngine& get_render_engine();

void init_gl();
void draw_text(std::string text, glm::vec2 point, Text_Flags flags);
