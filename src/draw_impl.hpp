void init_gl() {
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
}

void draw_text(std::string text, glm::vec2 point, Text_Flags flags) {
	TextRenderInfo info;
	info.text = text;
	info.point = point;
	info.flags = flags;

	auto& render_engine = get_render_engine();
	render_engine.text_infos.push_back(info);
}

RenderEngine& get_render_engine() {
	static RenderEngine engine;
	return engine;
}

void RenderEngine::init() {
	glGenFramebuffers(1, &frame_buffer);
	glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer);

	// Generate the color buffer, allocate GPU memory for it, and attach it to the frame buffer
	glGenTextures(1, &color_buffer);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, color_buffer);	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 2560, 1440, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_buffer, 0);
	
	auto status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (status != GL_FRAMEBUFFER_COMPLETE) {
		tdns_log.write("@incomplete_frame_buffer: " + std::to_string(status));
	}

	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

Camera& RenderEngine::get_camera() {
	return camera;
}

void RenderEngine::render(float dt) {	
	render_text(dt);
}

void RenderEngine::render_text(float dt) {
	auto& shaders = get_shader_manager();
	auto shader = shaders.get("text");
	shader->begin();

	auto& font = g_fonts[g_dialogue_font];

	// Text is raw 2D, so just use an orthographic projection
	SRT transform = SRT::no_transform();
	glm::mat3 mat = mat3_from_transform(transform);
	shader->set_mat3("transform", mat);
	shader->set_int("sampler", 0);

	glBindBuffer(GL_ARRAY_BUFFER, font_vert_buffer);
	glBindVertexArray(font_vao);

	for (const auto& info : text_infos) {
		auto color = has_flag(info.flags, Text_Flags::Highlighted) ? Colors::TextHighlighted : Colors::TextWhite;
		shader->set_vec3("text_color", color);

		auto px_point = px_from_screen(info.point);
		for (auto c : info.text) {
			Character& freetype_char = font.characters[c];
		
			GLfloat left = static_cast<float>(px_point.x) + freetype_char.px_bearing.x;
			GLfloat right = left + freetype_char.px_size.x;
			GLfloat bottom = static_cast<float>(px_point.y) - (freetype_char.px_size.y - freetype_char.px_bearing.y); // Put the bearing point, not the bottom of the glyph, at requested Y
			GLfloat top = bottom + freetype_char.px_size.y;
			
			gl_unit gl_left = gl_from_screen(screen_x_from_px((pixel_unit)left));
			gl_unit gl_right = gl_from_screen(screen_x_from_px((pixel_unit)right));
			gl_unit gl_bottom = gl_from_screen(screen_y_from_px((pixel_unit)bottom));
			gl_unit gl_top = gl_from_screen(screen_y_from_px((pixel_unit)top));
			
			// FreeType loads the fonts upside down, which is why texture coordinates look wonky
			GLfloat vertices[12][2] = {
				// Vertices 
				{ gl_left,  gl_top },
				{ gl_left,  gl_bottom },
				{ gl_right, gl_bottom },
			
				{ gl_left,  gl_top },
				{ gl_right, gl_bottom },
				{ gl_right, gl_top },
			
				// Texture coordinates
				{ 0.f, 0.f },
				{ 0.f, 1.f },
				{ 1.f, 1.f },
			
				{ 0.f, 0.f },
				{ 1.f, 1.f },
				{ 1.f, 0.f }
			};
			
			// Render glyph texture over quad
			glActiveTexture(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, freetype_char.texture);
			glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
			
			shader->check();
			glDrawArrays(GL_TRIANGLES, 0, 6);
		
			px_point.x += (freetype_char.advance / 64);
		}
	}
	shader->end();
	text_infos.clear();
}
