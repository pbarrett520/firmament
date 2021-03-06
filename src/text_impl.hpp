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

void move_point_down(Vector2* point, float distance) {
	point->y -= distance;
}

void move_point_up(Vector2* point, float distance) {
	point->y += distance;
}

void text_ctx_init(TextRenderContext* ctx, FontInfo* font) {
	ctx->font = font;
	ctx->point = {
		ctx->position.x + ctx->padding.x,
		ctx->position.y
	};

	ctx->max_lines = (int32)floorf((ctx->dimension.y - ctx->padding.y) / font->max_advance.y);
	ctx->max_lines--;

	ctx->chunks_to_render = ctx->infos->size;
}

void text_ctx_start_at_bottom(TextRenderContext* ctx) {
	move_point_down(&ctx->point, ctx->dimension.y);
	move_point_up(&ctx->point, ctx->padding.y);
	move_point_down(&ctx->point, ctx->font->descender);
}

void text_ctx_start_at_top(TextRenderContext* ctx) {
	move_point_down(&ctx->point, ctx->padding.y);
	move_point_down(&ctx->point, ctx->padding.y); // @bug
}

bool text_ctx_done(TextRenderContext* ctx) {
	return ctx->chunks_rendered == ctx->chunks_to_render;
}

TextRenderInfo* text_ctx_chunk(TextRenderContext* ctx) {
	ctx->is_chunk_done = false;
	
	// A line of separation between chunks, except the first time this is called
	if (ctx->do_chunk_separator) {
		move_point_down(&ctx->point, ctx->font->max_advance.y);
	}
	ctx->do_chunk_separator = true;

	// Reset the point
	ctx->point.x = ctx->position.x + ctx->padding.x;

	// Start on first line
	ctx->ib_low = 0;
	ctx->ib_hi = 1;

	auto info = arr_at(ctx->infos, ctx->next_chunk_index);
	ctx->info = info;
	ctx->next_chunk_index++;
	ctx->chunks_rendered++;

	return info;
}

bool text_ctx_chunkdone(TextRenderContext* ctx) {
	return ctx->is_chunk_done;
}

ArrayView<char> text_ctx_readline(TextRenderContext* ctx) {
	int32 this_break = ctx->info->lbreaks[ctx->ib_low];
	int32 last_break = ctx->info->lbreaks[ctx->ib_hi];
	return arr_view(arr_to_ptr(ctx->info->text) + this_break, last_break - this_break);
}

void text_ctx_nextline(TextRenderContext* ctx) {
	ctx->point.x = ctx->position.x + ctx->padding.x;
	move_point_down(&ctx->point, ctx->font->max_advance.y);
	ctx->ib_low++;
	ctx->ib_hi++;

	ctx->is_chunk_done = ctx->ib_hi == ctx->info->count_lb;
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
	
	if (input.scroll.y > 0) mtb->line_scroll = fox_min(mtb->line_scroll++, text_buffer.size);
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

void lbctx_init(LineBreakContext* context) {
	arr_push(context->line_breaks, 0);
	context->point     = context->position.x + context->padding.x;
	context->point_max = context->position.x + context->dimension.x - context->padding.x;
}

void lbctx_advance_no_break(LineBreakContext* context, const char* text, int32 len) {
	FontInfo* font = font_infos[0];
	for (int32 i = 0; i < len; i++) {
		GlyphInfo* glyph = font->glyphs[text[i]];
		context->point += glyph->advance.x;
	}
}

void lbctx_advance(LineBreakContext* context, ArrayView<char> text) {
	context->last_text = text;
	FontInfo* font = font_infos[0];
	
	arr_for(text, c) {
		if (*c == 0) break;
		GlyphInfo* glyph = font->glyphs[*c];
	
		context->point += glyph->advance.x;
		if (context->point >= context->point_max) {
			arr_push(context->line_breaks, arr_indexof(&text, c));
			context->point = context->position.x + context->padding.x;
		}
	}
}

void lbctx_finish(LineBreakContext* context) {
	arr_push(context->line_breaks, context->last_text.size);
}
