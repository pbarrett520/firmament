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

bool is_speaker(EffectRenderData* data, int32 vi) {
	int32 ci = vi / 6;
	return ci < data->speaker_len;
}

bool is_effect_range(TextEffect* effect, int32 vi) {
	// Both limits are zero means that it's on all the text
	if (!effect->first && !effect->last) return true;
	
	int32 ci = vi / 6;
	bool before = ci < effect->first;
	bool after  = ci > effect->last;
	return !before && !after;
}
