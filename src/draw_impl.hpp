void init_gl() {
	auto& render_engine = get_render_engine();
	
	GLint flags;
	glGetIntegerv(GL_CONTEXT_FLAGS, &flags);
	if (flags & GL_CONTEXT_FLAG_DEBUG_BIT) {
		glEnable(GL_DEBUG_OUTPUT);
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
		glDebugMessageCallbackKHR(gl_debug_callback, nullptr);
		glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, nullptr, GL_TRUE);
	}
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);

	// GPU buffer 1 layout:
	// [ quads for each character | texcoords for each character ]
	//
	// Both quads and texcoords are generated when we load the font -- we use the font size, plus the character's
	// metrics (bearing, size), to make a quad. And then we use the bitmaps we load from the TTF file to create a
	// texture atlas -- texcoords are with respect to this atlas.
	
	// Start the VAO
	glGenVertexArrays(1, &render_engine.vao);
	glBindVertexArray(render_engine.vao);

	// Create a GPU buffer large enough to hold all the vertices and tex coords
	glGenBuffers(1, &render_engine.buffer);
	glBindBuffer(GL_ARRAY_BUFFER, render_engine.buffer);
	
	int32 gpu_buffer_size = 0;
	gpu_buffer_size += arr_bytes(&vx_buffer); // Vertex
	gpu_buffer_size += arr_bytes(&tc_buffer); // Texture coordinate
	gpu_buffer_size += arr_bytes(&cr_buffer); // Color
	glBufferData(GL_ARRAY_BUFFER, gpu_buffer_size, NULL, GL_DYNAMIC_DRAW);

	// Buffer attributes
	int32 gpu_offset = 0;
	
	// First attribute: 2D vertices
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(0));
	glEnableVertexAttribArray(0);
	gpu_offset += arr_bytes(&vx_buffer);

	// Second attribute: 2D Texture coordinates
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(gpu_offset));
	glEnableVertexAttribArray(1);
	gpu_offset += arr_bytes(&tc_buffer);

	// Third attribute: 4D Colors
	glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(gpu_offset));
	glEnableVertexAttribArray(2);
	

	// GPU buffer 2 layout:
	// [ vertices for each character  ]
	//
	// This buffer is for rendering untextured debug geometry over stuff in the game. You
	// can color it with a uniform in the shader.
	
	// Create a GPU buffer and VAO
	glGenVertexArrays(1, &render_engine.dbg_vao);
	glBindVertexArray(render_engine.dbg_vao);

	gpu_buffer_size = 0;
	gpu_buffer_size += arr_bytes(&dbg_vx_buffer);
	gpu_buffer_size += arr_bytes(&dbg_cr_buffer);
	glGenBuffers(1, &render_engine.dbg_buffer);
	glBindBuffer(GL_ARRAY_BUFFER, render_engine.dbg_buffer);
	glBufferData(GL_ARRAY_BUFFER, gpu_buffer_size, NULL, GL_DYNAMIC_DRAW);

	gpu_offset = 0;

	// First attribute: 2D vertices
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(0));
	glEnableVertexAttribArray(0);
	gpu_offset += arr_bytes(&dbg_vx_buffer);

	// Second attribute: 4D colors
	glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(gpu_offset));
	glEnableVertexAttribArray(1);
}

// The order of these matter -- we use an enum field to index the text box array
void init_tbox() {
	TextBox* main = arr_push(&tbox_data);
	main->pos = {
		-2.f / 3.f, // 1/6 of the screen from the left side
		1
	};
	main->dim = {
		4.f / 3.f, // take up 2/3 of the screen horizontally
		1.5f       // take up 3/4 of the screen vertically
	};
	main->pad = { .025f, .025f };
	main->dbg_color = colors::dbg_textbox;

	// hardcode!!!!!!!
	main_box.pos = {
		-2.f / 3.f, // 1/6 of the screen from the left side
		1
	};
	main_box.dim = {
		4.f / 3.f, // take up 2/3 of the screen horizontally
		1.5f       // take up 3/4 of the screen vertically
	};
	main_box.pad = { .025f, .025f };
	main_box.dbg_color = colors::dbg_textbox;
	
	TextBox* choice = arr_push(&tbox_data);
	choice->pos = {
		-2.f / 3.f,
		-.5f  // start 3/4 down the screen (adjacent to text box)
	};
	choice->dim = {
		4.f / 3.f, // take up 2/3 of the screen horizontally
		.5f        // take up 1/4 of the screen vertically
	};
	choice->pad = { .025f, .025f };
	choice->dbg_color = colors::dbg_choicebox;
}

RenderEngine& get_render_engine() {
	static RenderEngine engine;
	return engine;
}

void text_ctx_init(TextRenderContext* ctx, TextBox* box, FontInfo* font) {
	ctx->box = box;
	ctx->font = font;
	ctx->point = {
		box->pos.x + box->pad.x,
		box->pos.y - box->dim.y + box->pad.y - font->descender
	};
}

void text_ctx_advance(TextRenderContext* ctx, GlyphInfo* glyph) {
	ctx->point.x += glyph->advance.x;
	ctx->written++;

	// Check if we need to advance the point in the Y axis due to a line break
	int32 next_lbreak = ctx->info->lbreaks[ctx->idx_break];
	if (next_lbreak == 0) return;
	if (next_lbreak != ctx->written) return;

	ctx->point.y -= ctx->font->descender;
}

void text_ctx_chunk(TextRenderContext* ctx, TextRenderInfo* info) {
	// First use
	if (!ctx->info) {
		ctx->info = info;
		return;
	}

	ctx->point.x = ctx->box->pos.x + ctx->box->pad.x;
	ctx->written = 0;
	ctx->idx_break = 0;

	int32 count_lines = 0;
	for (int32 i = 0; i < MAX_LINE_BREAKS; i++) {
		if (!ctx->info->lbreaks[i]) break;
		count_lines++;
	}

	ctx->point.y += ctx->font->max_advance.y * (count_lines + 1);
}


void RenderEngine::render(float dt) {	
	render_dbg_geometry(dt);
	render_text(dt);
}

void RenderEngine::render_dbg_geometry(float dt) {
	if (!dbg_rq_buffer.size) return;
	
	auto& shaders = get_shader_manager();
	auto shader = shaders.get("solid");
	shader->begin();

	// Fill the color buffer with the standard white color
	arr_fastclear(&dbg_vx_buffer);
	arr_fastclear(&dbg_cr_buffer);

	arr_for(dbg_rq_buffer, rq) {
		// Generate vertices for whatever kind of request it is
		if (rq->type == DbgRenderType::RECT) {
			float32 top = rq->pos.y;
			float32 bottom = rq->pos.y - rq->data.rect.sy;
			float32 left = rq->pos.x;
			float32 right = rq->pos.x + rq->data.rect.sx;
			
			Vector2 vxs [6] = fm_quad(top, bottom, left, right);
			arr_push(&dbg_vx_buffer, vxs, 6);

			Vector4 colors [6] = fm_quad_color(rq->color);
			arr_push(&dbg_cr_buffer, colors, 6);
		}
		else if (rq->type == DbgRenderType::TEXT_BOX) {
			int32 index = static_cast<int32>(rq->data.tbox.type);
			TextBox* box = tbox_data[index];
			
			float32 top = box->pos.y;
			float32 bottom = box->pos.y - box->dim.y;
			float32 left = box->pos.x;
			float32 right = box->pos.x + box->dim.x;

			Vector2 vxs [6] = fm_quad(top, bottom, left, right);
			arr_push(&dbg_vx_buffer, vxs, 6);

			Vector4 colors [6] = fm_quad_color(box->dbg_color);
			arr_push(&dbg_cr_buffer, colors, 6);
		}
	}

	glBindBuffer(GL_ARRAY_BUFFER, dbg_buffer);
	glBindVertexArray(dbg_vao);

	int32 gpu_offset = 0;
	
	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&dbg_vx_buffer),
					dbg_vx_buffer.data);
	gpu_offset += arr_bytes(&dbg_vx_buffer);
	
	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&dbg_cr_buffer),
					dbg_cr_buffer.data);
	
	shader->check();
	glDrawArrays(GL_TRIANGLES, 0, dbg_vx_buffer.size);
	shader->end();
	
	arr_clear(&dbg_rq_buffer);
}

void RenderEngine::render_text(float dt) {
	if (!text_buffer.size) return;

	TextBox* main_box = tbox_data[static_cast<int32>(TextBoxType::MAIN)];
	TextRenderContext context;
	text_ctx_init(&context, main_box, font_infos[0]);
	
	auto& shaders = get_shader_manager();
	auto shader = shaders.get("text");
	shader->begin();
	
	shader->set_int("sampler", 0);

	// Fill the color buffer with the standard white color
	arr_fill(&cr_buffer, colors::white);
	arr_fastclear(&vx_buffer);
	arr_fastclear(&tc_buffer);

	// get baseline point
	// iterate through text requests backwards
	// calculate how many lines must be rendered (pre-calculated)
	// move the point up that many lines
	// iterate through each character, render, move point down for newlines
	// apply effects
	// move line up [count_lines_written] + 1

	arr_rfor(text_buffer, info) {
		text_ctx_chunk(&context, info);
		
		int32 vx_begin = vx_buffer.size;
		int32 cr_begin = cr_buffer.size;
		int32 count_vx = 0;

		// Transform vertices by the point and copy them into the intermediate bufer
		ArrayView<char> text = arr_view(info->text, MAX_TEXT_LEN);
		arr_for(text, c) {
			if (*c == 0) break;
			GlyphInfo* glyph = glyph_infos[*c];

			Vector2* vx = arr_push(&vx_buffer, &glyph->mesh->verts[0], glyph->mesh->count);
			Vector2* tc = arr_push(&tc_buffer, &glyph->mesh->tex_coords[0], glyph->mesh->count);
			count_vx += glyph->mesh->count;

			Vector2 gl_origin = { -1, 1 };
			Vector2 offset = {
				context.point.x - gl_origin.x,
				context.point.y - gl_origin.y,
			};
			for (int32 i = 0; i < glyph->mesh->count; i++) {
				vx[i].x += offset.x;
				vx[i].y += offset.y;
			}

			text_ctx_advance(&context, glyph);
		}

		// Get the pointer to the memory blocks we just wrote for this text's GPU data, and pass
		// those to the text's effects to modify
		auto vx = arr_slice(&vx_buffer, vx_begin, count_vx);
		auto tc = arr_slice(&tc_buffer, vx_begin, count_vx);
		auto cr = arr_slice(&cr_buffer, vx_begin, count_vx);
		arr_for(info->effects, effect) {
			auto do_effect = effect_f[(int32)effect->type];
			do_effect(effect, dt, vx, tc, cr);
			effect->frames_elapsed++;
		}
	}

	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glBindVertexArray(vao);

	// Use the font atlas texture
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture);

	int32 gpu_offset = 0;
	
	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&vx_buffer),
					vx_buffer.data);
	gpu_offset += arr_bytes(&vx_buffer);
	
	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&tc_buffer),
					tc_buffer.data);
	gpu_offset += arr_bytes(&tc_buffer);

	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&cr_buffer),
					cr_buffer.data);
	
	shader->check();
	glDrawArrays(GL_TRIANGLES, 0, vx_buffer.size);
	shader->end();
}

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
	float32 sinv2 = sinf((effect->frames_elapsed - 20) / oscillate->frequency) * oscillate->amplitude;
	arr_for(vx_data, vx) {
		int32 vi = vx - vx_data.data;
		int32 ci = vi / 6;
		if (ci % 2) vx->y -= sinv;
		else vx->y += sinv2;
	}
	
	tdns_log.write("DoOscillateEffect: %f, %d", sinv, effect->frames_elapsed);
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
	tdns_log.write("r = %f, g = %f, b = %f", sinr, sing, sinb);
}
