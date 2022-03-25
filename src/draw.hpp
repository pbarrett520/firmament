struct Mesh {
	Vector2* verts      = nullptr;
	Vector2* tex_coords = nullptr;
	int32 count         = 0;
};

//
// Text effects
//
struct TextEffect;
enum class TextEffectType {
	NONE      = 0,
	OSCILLATE = 1,
	RAINBOW   = 2,
	COUNT     = RAINBOW + 1,
};
constexpr int32 COUNT_TEXT_EFFECTS = static_cast<int32>(TextEffectType::COUNT);

// Text effect implementations. Each effect consists of two things:
// 1. A struct containing the data for the effect, which is unioned into a TextEffect struct
// 2. A function to implement the effect.
//
// Effect functions accept the following parameters:
// - dt
// - A non-owning array which points to the vertices for the characters the effect is intended to modify
// - A non-owning array which points to the texcoords for the characters the effect is intended to modify

void DoNoneEffect(TextEffect* effect, float32 dt, Array<Vector2> vx, Array<Vector2> tc, Array<Vector4> clr);

struct OscillateEffect {
	float32 amplitude;
	float32 frequency;
};
void DoOscillateEffect(TextEffect* effect, float32 dt, Array<Vector2> vx, Array<Vector2> tc, Array<Vector4> clr);

struct RainbowEffect {
	int32 frequency;
};
void DoRainbowEffect(TextEffect* effect, float32 dt, Array<Vector2> vx, Array<Vector2> tc, Array<Vector4> clr);

// All effects. Indexed by effect type to get the correct functor.
typedef void (*TextEffectF)(TextEffect*, float32, Array<Vector2>, Array<Vector2>, Array<Vector4>);
TextEffectF effect_f [COUNT_TEXT_EFFECTS] = {
	&DoNoneEffect,
	&DoOscillateEffect,
	&DoRainbowEffect
};

// The struct that contains everything an effect function needs to modify character data
union EffectData {
	OscillateEffect oscillate;
	RainbowEffect   rainbow;
};

struct TextEffect {
	TextEffectType type = TextEffectType::NONE;
	int frames_elapsed = 0;
	EffectData data;
};

// The main text box, and the request to push text items to it
struct TextBox {
	Vector2 pos;
	Vector2 dim;
	Vector2 pad;
	Vector4 dbg_color;
};

struct MainTextBox {
	Vector2 pos;
	Vector2 dim;
	Vector2 pad;
	Vector4 dbg_color;	
};

MainTextBox main_box;

// @cleanup
enum class TextBoxType {
	MAIN = 0,
	CHOICE = 1
};

#define MAX_TEXT_LEN 1024
#define MAX_LINE_BREAKS 16
struct TextRenderInfo {
	char text [MAX_TEXT_LEN] = { 0 };
	int32 lbreaks [MAX_LINE_BREAKS] = { 0 };
	Array<TextEffect> effects = { 0 };
};

// Requests for drawing debug geometry
enum class DbgRenderType {
	RECT = 1,
	TEXT_BOX = 2
};

struct DbgRenderRect {
	float sx;
	float sy;
};

struct DbgRenderTextBox {
	TextBoxType type;
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
};

// Used for smoothing over advancing the point when rendering characters
struct TextRenderContext {
	TextBox* box          = nullptr;
	TextRenderInfo* info  = nullptr;
	FontInfo* font        = nullptr;

	Vector2 point;
	int32 written         = 0;
	int32 idx_break       = 0;
};

void text_ctx_init(TextRenderContext* ctx, TextBox* box, TextRenderInfo* info, FontInfo* font);
void text_ctx_advance(TextRenderContext* ctx, GlyphInfo* glyph);
void text_ctx_chunk(TextRenderContext* ctx, TextRenderInfo* chunk);


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
void init_tbox();
void init_render_engine();
