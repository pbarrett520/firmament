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

RenderEngine& get_render_engine() {
	static RenderEngine engine;
	return engine;
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
			if (rq->data.tbox.render_main) {
				arr_push(&dbg_vx_buffer, main_box.mesh->verts, main_box.mesh->count);
				Vector4 colors [6] = fm_quad_color(main_box.dbg_color);
				arr_push(&dbg_cr_buffer, colors, 6);
			}
			
			if (rq->data.tbox.render_choice) {
				arr_push(&dbg_vx_buffer, choice_box.mesh->verts, choice_box.mesh->count);
				Vector4 colors [6] = fm_quad_color(choice_box.dbg_color);
				arr_push(&dbg_cr_buffer, colors, 6);
			}
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

	TextRenderContext context;
	text_ctx_init(&context, font_infos[0]);
	
	auto& shaders = get_shader_manager();
	auto shader = shaders.get("text");
	shader->begin();
	
	shader->set_int("sampler", 0);

	// Fill the color buffer with the standard white color
	arr_fill(&cr_buffer, colors::white);
	arr_fastclear(&vx_buffer);
	arr_fastclear(&tc_buffer);

	arr_rfor(text_buffer, info) {
		if (text_ctx_full(&context)) break;
		text_ctx_chunk(&context, info);
		
		int32 vx_begin = vx_buffer.size;
		int32 cr_begin = cr_buffer.size;
		int32 count_vx = 0;
		
		// Algorithm: Iterate through requests in LIFO order, so that the newest requests are rendered
		// first. Then, iterate over their line breaks, starting from the last line. Iterate the line,
		// and move to the line above. Move to the next request.
		while (!text_ctx_chunkdone(&context)) {
			auto line = text_ctx_readline(&context);
			
			arr_for(line, c) {
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

			text_ctx_nextline(&context);
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
