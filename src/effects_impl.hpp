#if 0
float32 perlin_smooth(float32 x) {
	return 3 * pow(x, 2) - 2 * pow(x, 3);
}

Vector2 perlin_gradient(Vector2 point) {
	return { 1.f, 1.f };
}

float32 perlin_noise(float32 x, float32 y) {
	Vector2 input = { x, y };
	
	Vector2 grid_00 = { fm_floor(x), fm_floor(y) };
	Vector2 grid_01 = { fm_floor(x), fm_ceil(y) };
	Vector2 grid_10 = { fm_ceil(x),  fm_floor(y) };
	Vector2 grid_11 = { fm_ceil(x),  fm_ceil(y) };
	
	Vector2 gradient_00 = perlin_gradient(grid_00);
	Vector2 gradient_01 = perlin_gradient(grid_01);
	Vector2 gradient_10 = perlin_gradient(grid_10);
	Vector2 gradient_11 = perlin_gradient(grid_11);
	
	Vector2 diff_00 = vec_sub(&input, &grid_00);
	Vector2 diff_01 = vec_sub(&input, &grid_01);
	Vector2 diff_10 = vec_sub(&input, &grid_10);
	Vector2 diff_11 = vec_sub(&input, &grid_11);

	float32 s = vec_dot(&gradient_00, &diff_00);
	float32 t = vec_dot(&gradient_10, &diff_10);
	float32 u = vec_dot(&gradient_01, &diff_01);
	float32 v = vec_dot(&gradient_11, &diff_11);

	float32 wx = perlin_smooth(input.x - fm_floor(x));
	float32 a = s + wx * (t - s);
	float32 b = u + wx * (v - u);

	float32 wy = perlin_smooth(input.y - fm_floor(y));
	return a + wy * (b - a);
}
#endif

bool is_effect_range(TextEffect* effect, int32 vi) {
	// Both limits are zero means that it's on all the text
	if (!effect->first && !effect->last) return true;
	
	int32 ci = vi / 6;
	bool before = ci < effect->first;
	bool after  = ci > effect->last;
	return !before && !after;
}

// Effects
void DoNoneEffect(TextEffect* effect, EffectRenderData* data) {
	fm_assert(!"DoNoneEffect");
}

void DoOscillateEffect(TextEffect* effect, EffectRenderData* data) {
    OscillateEffect* oscillate = &effect->data.oscillate;

	float32 sinv = sinf(effect->frames_elapsed / oscillate->frequency) * oscillate->amplitude;
	arr_for(data->vx, vx) {
		int32 vi = arr_indexof(&data->vx, vx);
		//if (is_speaker(data, vi)) continue;
		if (!is_effect_range(effect, vi)) continue;

		int32 ci = vi / 6;
		vx->y -= sinv;
	}
}

void DoRainbowEffect(TextEffect* effect, EffectRenderData* data) {
    RainbowEffect* rainbow = &effect->data.rainbow;
    float32 pi = 3.14f;

	float32 sin_input = effect->frames_elapsed / (float32)rainbow->frequency;
	float32 sinr = clamp(sinf(sin_input), .3f, 1.f);
	float32 sing = clamp(sinf(sin_input + (pi / 4)), .3f, 1.f);
	float32 sinb = clamp(sinf(sin_input + (pi / 2)), .3f, 1.f);
	arr_for(data->clr, clr) {
		int32 vi = arr_indexof(&data->clr, clr);
		//if (is_speaker(data, vi)) continue;
		if (!is_effect_range(effect, vi)) continue;
		
		int32 ci = vi / 6;
		if      (!(ci % 3)) { clr->r *= sing; clr->g *= sinb; clr->b *= sinr; }
		else if (!(ci % 2)) { clr->r *= sinb; clr->g *= sinr; clr->b *= sing; }
		else                { clr->r *= sinr; clr->g *= sing; clr->b *= sinb; }
		
	}
}

void DoHazyWakeEffect(TextEffect* effect, EffectRenderData* data) {
	float32 sin_input = effect->frames_elapsed / 100.f;
	float32 sinv = sinf(sin_input);
	arr_for(data->tc, tc) {
		
	}
}

