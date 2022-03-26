struct Mesh {
	Vector2* verts      = nullptr;
	Vector2* tex_coords = nullptr;
	int32 count         = 0;
};

// Requests for drawing debug geometry
enum class DbgRenderType {
	NONE = 0,
	RECT = 1,
	TEXT_BOX = 2
};

struct DbgRenderRect {
	float sx;
	float sy;
};
struct DbgRenderTextBox {
	bool render_main;
	bool render_choice;
};
union DbgRenderData {
	DbgRenderRect rect;
	DbgRenderTextBox tbox;
};

struct DbgRenderRequest {
	DbgRenderType type;
	Vector2 pos;
	Vector4 color = { 1.f, 0.f, 0.f, .5f };

	DbgRenderData data;

	DbgRenderRequest() { type = DbgRenderType::NONE; data = {0}; }
};

struct RenderEngine {
	uint32 buffer;
	uint32 vao;
	uint32 texture;

	uint32 dbg_buffer;
	uint32 dbg_vao;
	
	void remove_entity(int entity);
	void render(float dt);
	void render_text(float dt);
	void render_dbg_geometry(float dt);
};
RenderEngine& get_render_engine();

void init_gl();
void init_render_engine();
