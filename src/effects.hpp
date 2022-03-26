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
struct NoneEffect {};
void DoNoneEffect(TextEffect* effect, float32 dt, Array<Vector2> vx, Array<Vector2> tc, Array<Vector4> clr);

struct OscillateEffect {
	float32 amplitude;
	float32 frequency;
	float32 rnd;
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
	NoneEffect      none;
	OscillateEffect oscillate;
	RainbowEffect   rainbow;
};

struct TextEffect {
	TextEffectType type = TextEffectType::NONE;
	int frames_elapsed = 0;
	EffectData data;
};
