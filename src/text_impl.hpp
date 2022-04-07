// The order of these matter -- we use an enum field to index the text box array
void init_text_boxes() {
	Mesh* mesh;
	float32 top, bottom, left, right;

	// Main box
	mesh = arr_push(&mesh_infos);
	top     = +1.000f;
	bottom  = -0.500f;
	left    = -0.667f;
	right   = +0.667f;
	Vector2 mvx [6] = fm_quad(top, bottom, left, right);
	mesh->verts = arr_push(&vx_data, arr_to_ptr(mvx), 6);
	mesh->count = 6;

	main_box.mesh = mesh;
	main_box.pos = { left, top };
	main_box.dim = { right - left, top - bottom };
	main_box.pad = { .025f, .025f };
	main_box.dbg_color = colors::dbg_textbox;

	// Choice box
	mesh = arr_push(&mesh_infos);
	top     = -0.500f;
	bottom  = -1.000f;
	left    = -0.667f;
	right   = +0.667f;
	Vector2 cvx [6] = fm_quad(top, bottom, left, right);
	mesh->verts = arr_push(&vx_data, arr_to_ptr(cvx), 6);
	mesh->count = 6;

	choice_box.mesh = mesh;
	choice_box.pos = { left, top };
	choice_box.dim = { right - left, top - bottom };
	choice_box.pad = { .025f, .025f };
	choice_box.dbg_color = colors::dbg_choicebox;
}

void cbx_init(ChoiceBox* cbx) {
	arr_init(&choice_buffer, MAX_CHOICES);
}

void cbx_add(ChoiceBox* cbx, ChoiceInfo choice) {
	arr_push(&choice_buffer, choice);
}

void cbx_clear(ChoiceBox* cbx) {
	arr_clear(&choice_buffer);
};

void choice_ctx_init(ChoiceRenderContext* ctx, FontInfo* font) {
	ctx->font = font;
	ctx->point = {
		choice_box.pos.x + choice_box.pad.x,
		choice_box.pos.y - choice_box.pad.y - font->ascender
	};
}

void choice_ctx_advance(ChoiceRenderContext* ctx, GlyphInfo* glyph) {
	ctx->point.x += glyph->advance.x;
}

void choice_ctx_nextline(ChoiceRenderContext* ctx) {
	ctx->point.x = choice_box.pos.x + choice_box.pad.x;
	ctx->point.y -= ctx->font->max_advance.y;
	ctx->point.y -= ctx->font->max_advance.y;
}

void text_ctx_init(TextRenderContext* ctx, FontInfo* font) {
	ctx->font = font;
	ctx->point = {
		main_box.pos.x + main_box.pad.x,
		main_box.pos.y - main_box.dim.y + main_box.pad.y - font->descender
	};

	ctx->max_lines = (int32)floorf((main_box.dim.y - main_box.pad.y) / font->max_advance.y);
	ctx->max_lines--;
}

void text_ctx_chunk(TextRenderContext* ctx, TextRenderInfo* info) {
	ctx->is_chunk_done = false;
	
	// A line of separation between chunks
	if (ctx->count_lines_written) {
		ctx->point.y += ctx->font->max_advance.y;
		ctx->count_lines_written++;
	}

	// Reset the point
	ctx->point.x = main_box.pos.x + main_box.pad.x;

	// Start on last line
	ctx->ib_low = info->count_lb - 2;
	ctx->ib_hi = info->count_lb - 1;

	// Check if we should skip this chunk
	auto mtb = &main_box;
	if (ctx->skipped < mtb->line_scroll) {
		ctx->skipped++;
		ctx->is_chunk_done = true;
	}

	
	ctx->info = info;
}

bool text_ctx_chunkdone(TextRenderContext* ctx) {
	return ctx->is_chunk_done;
}

bool text_ctx_full(TextRenderContext* ctx) {
	return ctx->count_lines_written == ctx->max_lines;
}

bool text_ctx_islast(TextRenderContext* ctx) {
	return ctx->ib_low == 0;
}

ArrayView<char> text_ctx_readline(TextRenderContext* ctx) {
	int32 this_break = ctx->info->lbreaks[ctx->ib_low];
	int32 last_break = ctx->info->lbreaks[ctx->ib_hi];
	return arr_view(arr_to_ptr(ctx->info->text) + this_break, last_break - this_break);
}

void text_ctx_nextline(TextRenderContext* ctx) {
	ctx->point.x = main_box.pos.x + main_box.pad.x;
	ctx->point.y += ctx->font->max_advance.y;
	ctx->ib_low--;
	ctx->ib_hi--;
	ctx->is_chunk_done = ctx->ib_low < 0;
	ctx->count_lines_written++;
}

void text_ctx_render(TextRenderContext* ctx, char c) {
	GlyphInfo* glyph = ctx->font->glyphs[c];

	Vector2* vx = arr_push(&vx_buffer, &glyph->mesh->verts[0], glyph->mesh->count);
	Vector2* tc = arr_push(&tc_buffer, &glyph->mesh->tex_coords[0], glyph->mesh->count);

	Vector2 gl_origin = { -1, 1 };
	Vector2 offset = {
		ctx->point.x - gl_origin.x,
		ctx->point.y - gl_origin.y,
	};
	for (int32 i = 0; i < glyph->mesh->count; i++) {
		vx[i].x += offset.x;
		vx[i].y += offset.y;
	}
}

void text_ctx_advance(TextRenderContext* ctx, char c) {
	GlyphInfo* glyph = ctx->font->glyphs[c];
	ctx->point.x += glyph->advance.x;
}

float32 text_ctx_scroll(TextRenderContext* ctx) {
	MainTextBox* mtb = &main_box;
	
	if (options::smooth_scroll) { return mtb->scroll_cur; }
	return mtb->line_scroll * ctx->font->max_advance.y;
	
}

void mtb_update_scroll(MainTextBox* mtb, float dt) {
	if (options::smooth_scroll) { mtb_update_scroll_smooth(mtb, dt); return; }
	
	auto& input = get_input_manager();
	
	if (input.scroll.y > 0) mtb->line_scroll++;
	else if (input.scroll.y < 0) mtb->line_scroll = fox_max(mtb->line_scroll--, 0);
}

void mtb_update_scroll_smooth(MainTextBox* mtb, float dt) {
	auto& input = get_input_manager();

	// First: Add the new scroll from this frame to the target
	mtb->scroll_tgt += (input.scroll.y * options::scroll_speed);

	// Check if we need to reset the accumulated lerp (i.e. start a new lerp)
	bool reset_lerp = true;
	
	// Don't reset lerp unless you started scrolling this frame.
	reset_lerp &= fm_floateq(mtb->last_frame_scroll, 0);
	reset_lerp &= !fm_floateq(input.scroll.y, 0);
	// But also, slow mouse scrolls can give small, jittery inputs (e.g. 1, 0, 1, 0, 1, 1). This would trick
	// us into thinking we just started scrolling -- not so. Resetting the lerp in this case would cause a
	// jerky scroll. To fix this, make sure that we've been stopped for some number of frames.
	reset_lerp &= mtb->frames_still > 3;
	// You could scroll, stop for a bit, and scroll again before the first scroll is complete. If we don't check
	// for that first lerp to complete, we'll reset it and get a jerky scroll
	reset_lerp &= fm_floateq(mtb->lerp_acc, options::scroll_lerp);
	if (reset_lerp) { mtb->lerp_acc = 0; mtb->scroll_lerpstart = mtb->scroll_cur; }

	// Do the lerp
	mtb->lerp_acc += dt;
	mtb->lerp_acc = fox_min(mtb->lerp_acc, options::scroll_lerp);
	mtb->scroll_cur = fm_lerp(mtb->scroll_lerpstart, mtb->scroll_tgt, mtb->lerp_acc / options::scroll_lerp);

	// We keep track of how many frames we've been still to avoid jittery scroll inputs
	// which would falsely mark us as not scrolling (e.g. 0, 1, 0, 1, 1, 0) 
	if (input.scroll.y)  mtb->frames_still = 0;
	else mtb->frames_still++;

	mtb->last_frame_scroll = input.scroll.y;
}
