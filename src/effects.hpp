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

struct EffectRenderData {
	float32 dt;
	Array<Vector2> vx;
	Array<Vector2> tc;
	Array<Vector4> clr;
	
	// Indices into the vertex buffer -- filled out dynamically as we render
	int32 speaker_begin = 0;
	int32 speaker_end = 0;
};


// Text effect implementations. Each effect consists of two things:
// 1. A struct containing the data for the effect, which is unioned into a TextEffect struct
// 2. A function to implement the effect.
//
// Effect functions accept the following parameters:
// - dt
// - A non-owning array which points to the vertices for the characters the effect is intended to modify
// - A non-owning array which points to the texcoords for the characters the effect is intended to modify
struct NoneEffect {};
void DoNoneEffect(TextEffect* effect, EffectRenderData* data);

struct OscillateEffect {
	float32 amplitude;
	float32 frequency;
	float32 rnd;
};
void DoOscillateEffect(TextEffect* effect, EffectRenderData* data);

struct RainbowEffect {
	int32 frequency;
};
void DoRainbowEffect(TextEffect* effect, EffectRenderData* data);


// All effects. Indexed by effect type to get the correct functor.
typedef void (*TextEffectF)(TextEffect*, EffectRenderData* data);
TextEffectF effect_f [COUNT_TEXT_EFFECTS] = {
	&DoNoneEffect,
	&DoOscillateEffect,
	&DoRainbowEffect
};


// The struct that contains everything an effect function needs to modify character data
union EffectData {
	NoneEffect      none;
	OscillateEffect oscillate;
	RainbowEffect   rainbow;
};

struct TextEffect {
	TextEffectType type = TextEffectType::NONE;
	int frames_elapsed = 0;
	
	// Character indices for which this effect is active
	int32 first = 0;
	int32 last = 0;
	
	EffectData data;
};

bool is_speaker(EffectRenderData* data, int32 vi);
bool is_effect_range(TextEffect* effect, int32 vi);
