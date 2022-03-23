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

	// GPU buffer layout:
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
	gpu_buffer_size += arr_bytes(&vertex_buffer); // Vertex
	gpu_buffer_size += arr_bytes(&tc_buffer); // Texture coordinate
	gpu_buffer_size += arr_bytes(&color_buffer); // Color
	glBufferData(GL_ARRAY_BUFFER, gpu_buffer_size, NULL, GL_DYNAMIC_DRAW);

	// Buffer attributes
	int32 gpu_offset = 0;
	
	// First attribute: 2D vertices
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(0));
	glEnableVertexAttribArray(0);
	gpu_offset += arr_bytes(&vertex_buffer);

	// Second attribute: 2D Texture coordinates
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(gpu_offset));
	glEnableVertexAttribArray(1);
	gpu_offset += arr_bytes(&tc_buffer);

	// Third attribute: 4D Colors
	glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, ogl_offset_to_ptr(gpu_offset));
	glEnableVertexAttribArray(2);
}

RenderEngine& get_render_engine() {
	static RenderEngine engine;
	return engine;
}

Camera& RenderEngine::get_camera() {
	return camera;
}

void RenderEngine::render(float dt) {	
	render_text(dt);
}

void RenderEngine::render_text(float dt) {
	if (!text_buffer.size) return;
	auto& shaders = get_shader_manager();
	auto shader = shaders.get("text");
	shader->begin();

	SRT transform = SRT::no_transform();
	glm::mat3 mat = mat3_from_transform(transform);
	shader->set_int("sampler", 0);

	// Fill the color buffer with the standard white color
	arr_fill(&color_buffer, colors::white);

	// Make intermediate buffers to hold vertices for this frame. We'll copy this to the GPU verbatim.
	Vector2        tmp_vx_data[VERT_BUFFER_SIZE];
	Array<Vector2> tmp_vx_buffer;
	arr_stack(&tmp_vx_buffer, &tmp_vx_data[0], VERT_BUFFER_SIZE);
	
	Vector2         tmp_tc_data[VERT_BUFFER_SIZE];
	Array<Vector2>  tmp_tc_buffer;
	arr_stack(&tmp_tc_buffer, &tmp_tc_data[0], VERT_BUFFER_SIZE);

	arr_for(text_buffer, info) {
		int32 vx_begin = tmp_vx_buffer.size;
		int32 count_elems = 0;
		Vector2 point = info->point;

		// Transform vertices by the point and copy them into the intermediate bufer
		Array<char> text = arr_view(info->text, MAX_TEXT_LEN);
		arr_for(text, c) {
			if (*c == 0) break;
			GlyphInfo* glyph = glyph_infos[*c];

			Vector2* tmp_vx = arr_push(&tmp_vx_buffer, &glyph->mesh->verts[0], glyph->mesh->count);
			Vector2* tmp_tc = arr_push(&tmp_tc_buffer, &glyph->mesh->tex_coords[0], glyph->mesh->count);
			count_elems += glyph->mesh->count;

			Vector2 gl_origin = { -1, 1 };
			Vector2 offset = {
				point.x - gl_origin.x,
				point.y - gl_origin.y,
			};
			for (int32 i = 0; i < glyph->mesh->count; i++) {
				tmp_vx[i].x += offset.x;
				tmp_vx[i].y += offset.y;
			}

			point.x += glyph->advance.x;
		}

		auto vx = arr_slice(&tmp_vx_buffer, vx_begin, count_elems);
		auto tc = arr_slice(&tmp_tc_buffer, vx_begin, count_elems);
		arr_for(info->effects, effect) {
			auto do_effect = effect_f[(int32)effect->type];
			do_effect(effect, dt, vx, tc, color_buffer);
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
					arr_bytes(&tmp_vx_buffer),
					tmp_vx_buffer.data);
	gpu_offset += arr_bytes(&vertex_buffer);
	
	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&tmp_tc_buffer),
					tmp_tc_buffer.data);
	gpu_offset += arr_bytes(&tc_buffer);

	glBufferSubData(GL_ARRAY_BUFFER,
					gpu_offset,
					arr_bytes(&color_buffer),
					color_buffer.data);
	
	shader->check();
	glDrawArrays(GL_TRIANGLES, 0, tmp_vx_buffer.size);
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
    float32 pi = 3.14;

	float32 sin_input = effect->frames_elapsed / (float32)rainbow->frequency;
	float32 sinr = clamp(sinf(sin_input), .3, 1);
	float32 sing = clamp(sinf(sin_input + (pi / 4)), .3, 1);
	float32 sinb = clamp(sinf(sin_input + (pi / 2)), .3, 1);
	arr_for(clr_data, clr) {
		int32 vi = clr - clr_data.data;
		int32 ci = vi / 6;
		if      (!(ci % 3)) { clr->r *= sing; clr->g *= sinb; clr->b *= sinr; }
		else if (!(ci % 2)) { clr->r *= sinb; clr->g *= sinr; clr->b *= sing; }
		else                { clr->r *= sinr; clr->g *= sing; clr->b *= sinb; }
		
	}
	tdns_log.write("r = %f, g = %f, b = %f", sinr, sing, sinb);
}
