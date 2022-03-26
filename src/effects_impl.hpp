// Effects
void DoNoneEffect(
    TextEffect* effect,
	float32 dt,
	Array<Vector2> vx_data, Array<Vector2> tc_data, Array<Vector4> clr_data
) {
	fm_assert(!"DoNoneEffect");
}

void DoOscillateEffect(
    TextEffect* effect,
	float32 dt,
	Array<Vector2> vx_data, Array<Vector2> tc_data, Array<Vector4> clr_data
) {
    OscillateEffect* oscillate = &effect->data.oscillate;

	float32 sinv = sinf(effect->frames_elapsed / oscillate->frequency) * oscillate->amplitude;
	float32 sinv2 = sinf((effect->frames_elapsed - (oscillate->rnd * 10)) / (oscillate->frequency * oscillate->rnd)) * oscillate->amplitude;
	arr_for(vx_data, vx) {
		int32 vi = vx - vx_data.data;
		int32 ci = vi / 6;
		if (ci % 2) vx->y -= sinv;
		else vx->y += sinv2;
	}

	#if 0
	auto qvs = arr_slice((fm_quadview*)vx_data.data, vx_data.size / 6);
	arr_for(qvs, qv) {
		qv->tl.x -= sinv;
		qv->tl2.x -= sinv;
		qv->tr.x -= sinv;

		qv->bl.x += sinv2;
		qv->br.x += sinv2;
		qv->br2.x += sinv2;
	}
	#endif
}

void DoRainbowEffect(
    TextEffect* effect,
	float32 dt,
	Array<Vector2> vx_data, Array<Vector2> tc_data, Array<Vector4> clr_data
) {
    RainbowEffect* rainbow = &effect->data.rainbow;
    float32 pi = 3.14f;

	float32 sin_input = effect->frames_elapsed / (float32)rainbow->frequency;
	float32 sinr = clamp(sinf(sin_input), .3f, 1.f);
	float32 sing = clamp(sinf(sin_input + (pi / 4)), .3f, 1.f);
	float32 sinb = clamp(sinf(sin_input + (pi / 2)), .3f, 1.f);
	arr_for(clr_data, clr) {
		int32 vi = clr - clr_data.data;
		int32 ci = vi / 6;
		if      (!(ci % 3)) { clr->r *= sing; clr->g *= sinb; clr->b *= sinr; }
		else if (!(ci % 2)) { clr->r *= sinb; clr->g *= sinr; clr->b *= sing; }
		else                { clr->r *= sinr; clr->g *= sing; clr->b *= sinb; }
		
	}
}
