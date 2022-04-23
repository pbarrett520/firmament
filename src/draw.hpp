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

// In this game, GPU buffers map 1:1 to CPU buffers. For example, we have a CPU buffer of vertices
// which we fill in each frame and send to the GPU verbatim. This context lets us fill the GPU buffers
// while keeping track of the running offset.
struct GlBufferContext {
	int32 offset = 0;
};
void glctx_sub_data(GlBufferContext* ctx, Array<Vector2>* arr) {
	glBufferSubData(GL_ARRAY_BUFFER,
					ctx->offset,
					arr->size * sizeof(Vector2),
					arr->data);
	ctx->offset += arr_bytes(arr);
};
void glctx_sub_data(GlBufferContext* ctx, Array<Vector4>* arr) {
	glBufferSubData(GL_ARRAY_BUFFER,
					ctx->offset,
					arr->size * sizeof(Vector4),
					arr->data);
	ctx->offset += arr_bytes(arr);
};
void glctx_reset(GlBufferContext* ctx) {
	ctx->offset = 0;
}
	
struct RenderEngine {
	uint32 buffer;
	uint32 vao;
	uint32 texture;

	uint32 dbg_buffer;
	uint32 dbg_vao;
	
	void render(float dt);
};
RenderEngine& get_render_engine();

void init_gl();
void init_render_engine();
void render_mtb(float32 dt);
void render_cbx();
void render_dbg_geometry();
void send_gpu_commands();
