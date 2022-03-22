struct Mesh {
	Vector2* verts      = nullptr;
	Vector2* tex_coords = nullptr;
	int32 count         = 0;
};

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
	Vector2 point;
	Text_Flags flags = Text_Flags::None;
};

struct RenderEngine {
	std::vector<std::function<void()>> primitives;
	std::vector<TextRenderInfo> text_infos;
	Camera camera;

	uint frame_buffer;
	uint color_buffer;
	
	uint32 buffer;
	uint32 vao;
	uint32 texture;
	
	void remove_entity(int entity);
	void render(float dt);
	void render_text(float dt);
	void render_text_old(float dt);
	Camera& get_camera();
};
RenderEngine& get_render_engine();

#define VERT_BUFFER_SIZE 8096
Array<Vector2>   vertex_buffer;
Array<Vector2>   tc_buffer;
Array<Mesh>      meshes;       

void init_gl();
void init_render_engine();

void draw_text(std::string text, glm::vec2 point, Text_Flags flags);
