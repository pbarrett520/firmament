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


union EffectData {
	OscillateEffect oscillate;
	RainbowEffect   rainbow;
};

struct TextEffect {
	TextEffectType type = TextEffectType::NONE;
	int frames_elapsed = 0;
	EffectData data;
};

#define MAX_TEXT_LEN 1024
#define MAX_LINE_BREAKS 16
struct TextRenderInfo {
	char text [MAX_TEXT_LEN] = { 0 };
	int32 lbreaks [MAX_LINE_BREAKS] = { 0 };
	Array<TextEffect> effects = { 0 };
};


struct TextBox {
	Vector2 pos = { -.5, .5 };
	Vector2 dim = { 1, 1 };
	Vector2 pad = { 0, 0 };
};
TextBox main_text_box;

Vector2 first_writeable_line(TextBox* text_box);

struct TextRenderContext {
	TextBox* box          = nullptr;
	TextRenderInfo* info  = nullptr;
	GlyphInfo* last_glyph = nullptr;
	Vector2 point;
	int32 written         = 0;
	int32 idx_break       = 0;
};

void text_ctx_init(TextRenderContext* ctx, TextBox* box, TextRenderInfo* info);
void text_ctx_advance(TextRenderContext* ctx, GlyphInfo* glyph);

struct RenderEngine {
	Camera camera;

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

void init_gl();
void init_render_engine();

void draw_text(std::string text, glm::vec2 point, Text_Flags flags);
