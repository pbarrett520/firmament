void init_imgui() {
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGui_ImplGlfwGL3_Init(g_window, false);
	
	auto& imgui = ImGui::GetIO();
	imgui.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
	ImGui::StyleColorsDark();

	auto imgui_font = imgui.Fonts->AddFontFromFileTTF(fm_ed_font_path, (float)fm_ed_font_size);

	imgui.IniFilename = nullptr;

	// Engine will pick this up on the first tick (before ImGui renders, so no flickering)
	API::use_layout("default");
}

void load_imgui_layout() {
	if (!strlen(layout_to_load)) return;

	ImGui::LoadIniSettingsFromDisk(layout_to_load);
	tdns_log.write(Log_Flags::File,
				   "load imgui layout: path = %s",
				   layout_to_load);

	memset(layout_to_load, 0, LAYOUT_MAXPATH);
}

void init_new_draw_stuff() {
	arr_init(&vertex_buffer, VERT_BUFFER_SIZE);
	arr_init(&tc_buffer, VERT_BUFFER_SIZE);
	arr_init(&meshes, 1024);
	arr_init(&glyph_infos, 128);

	FT_Library fm_freetype;
	
	if (FT_Init_FreeType(&fm_freetype)) {
		tdns_log.write("Failed to initialize FreeType");
		exit(0);
	}
	
	//init_font(fm_gm_font_path, fm_gm_font_size);
	
	FT_Face face = nullptr;
	if (FT_New_Face(fm_freetype, fm_gm_font_path, 0, &face)) {
		tdns_log.write(Log_Flags::Console,
					  "failed to load font, font = %s",
					  fm_gm_font_path);
		return;
	}
	
	int32 ft_font_size = px_to_ft(fm_gm_font_size); // Scaled to FT's units, where 26.6 units = 1 pixel
	FT_Set_Char_Size(face, 0, ft_font_size, 0, 0);

	/* 
	Font font;
	font.name = fm_gm_font;
	font.path = fm_gm_font_path;
	font.size = fm_gm_font_size;
	*/
	
	int num_glyphs = 128;
	
	int32 font_height_px = ft_to_px(face->size->metrics.height);
	int32 glyphs_per_row = static_cast<int32>(ceil(sqrt(128)));
	
	int tex_height = font_height_px * glyphs_per_row;
	int tex_width = tex_height;
	char* buffer = (char*)calloc(tex_width * tex_height, sizeof(char));
	// for (int32 i = 0; i < tex_width * tex_height; i++) {
	// 	buffer[i] = 0b11111010;
	// }
	

	Vector2 point;
	for (GLubyte c = 0; c < num_glyphs; c++) {
		int failure = FT_Load_Char(face, c, FT_LOAD_RENDER);
		if (failure) {
			tdns_log.write(Log_Flags::Console,
						   "failed to load character, char = %c",
						   c);
			return;
		}

		// Copy this bitmap into the atlas buffer
		FT_Bitmap* bitmap = &face->glyph->bitmap;

		if (point.x + bitmap->width > tex_width) {
			point.x = 0;
			point.y += font_height_px + 1;
		}

		for (int row = 0; row < bitmap->rows; row++) {
			for (int32 col = 0; col < bitmap->width; col++) {
				int32 x = (int32)(point.x + col);
				int32 y = (int32)(point.y + row);
				int32 ia = y * tex_width + x;
				int32 ib = row * bitmap->pitch + col;
				buffer[ia] = bitmap->buffer[ib];
			}
		}

		GlyphInfo* info = glyph_infos[c];
		info->size    = { (float32)face->glyph->bitmap.width, (float32)face->glyph->bitmap.rows };
		info->bearing = { (float32)face->glyph->bitmap_left,  (float32)face->glyph->bitmap_top };

		// Build the mesh, put the data the GPU needs in the appropriate buffer
		Mesh* mesh = arr_push(&meshes);

		mesh->count = 6;
		
		gl_unit gl_left = -1;
		gl_unit gl_right = gl_left + magnitude_gl_from_screen(screen_x_from_px(info->size.x));
		gl_unit gl_top = 1;
		gl_unit gl_bottom = gl_top - magnitude_gl_from_screen(screen_y_from_px(info->size.y));
		Vector2 vertices[6] = {
				{ gl_left,  gl_top },
				{ gl_left,  gl_bottom },
				{ gl_right, gl_bottom },
			
				{ gl_left,  gl_top },
				{ gl_right, gl_bottom },
				{ gl_right, gl_top },
		};
		mesh->verts = arr_push(&vertex_buffer, vertices, 6);

		float tc_left = point.x / tex_width;
		float tc_right = (point.x + info->size.x) / tex_width;
		float tc_top = 1 - (point.y / tex_height);
		float tc_bottom = 1 - ((point.y + info->size.y) / tex_height);
		Vector2 tex_coords[6] = {
				{ tc_left,  tc_top },
				{ tc_left,  tc_bottom },
				{ tc_right, tc_bottom },
			
				{ tc_left,  tc_top },
				{ tc_right, tc_bottom },
				{ tc_right, tc_top },
		};
		mesh->tex_coords = arr_push(&tc_buffer, tex_coords, 6);

		info->mesh = mesh;
		
		// Advance the point horizontally for the next character
		point.x += bitmap->width + 1;
	}

	auto& render_engine = get_render_engine();
	TextRenderInfo render_info;
	render_info.text = "F";
	render_engine.text_infos.push_back(render_info);

	char* tmp = (char*)calloc(tex_width, sizeof(char));
	for (int32 i = 0; i != tex_height / 2; i++) {
		char* top = buffer + (i * tex_width); // first element of top row
		char* btm = buffer + ((tex_height - i - 1) * tex_width); // first element of bottom row
		memcpy(tmp, top, tex_width);
		memcpy(top, btm, tex_width);
		memcpy(btm, tmp, tex_width);
	}

		stbi_write_png(fm_atlas_gm, tex_width, tex_height, 1, buffer, tex_width);

	glGenTextures(1, &render_engine.texture);
	glBindTexture(GL_TEXTURE_2D, render_engine.texture);
	glTexImage2D(GL_TEXTURE_2D,0, GL_RED, tex_width, tex_height, 0, GL_RED, GL_UNSIGNED_BYTE, buffer);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	FT_Done_Face(face);
	FT_Done_FreeType(fm_freetype);

	// Start the VAO
	glGenVertexArrays(1, &render_engine.vao);
	glBindVertexArray(render_engine.vao);

	// Create a GPU buffer large enough to hold all the vertices and tex coords
	glGenBuffers(1, &render_engine.buffer);
	glBindBuffer(GL_ARRAY_BUFFER, render_engine.buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vector2) * VERT_BUFFER_SIZE * 2, NULL, GL_DYNAMIC_DRAW);

	// Buffer attributes
	// First attribute: tightly packed 2D vertices
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(0);

	// Second attribute: tightly packed texcoords, after all the vertices
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)arr_bytes(&vertex_buffer));
	glEnableVertexAttribArray(1);
	// 1. Loop through the font:
	// - Generate a texture atlas from the font, filling the texture coordinate buffer
	// - Fill the vertex buffer with calculated vertices
	
	// 2. Allocate a GPU buffer for vertices and texture coordinates for each character
	// 3. Create a VAO and vertex attributes for the vertices and texture coordinates

	// ... during update
	// Requests to render text are submitted to a buffer

	// ... during render
	// For each request:
	// Transform the vertices for each character
	// Put them in an intermediate buffer
	// Put the texture coordinates in another intermediate buffer
	//
	// glBufferSubData
	// glDrawArrays
	

	Vector2 dialogue_box[] = {
		1.f,  1.f,
		1.f, -1.f,
		-1.f, -1.f,
		-1.f,  1.f
	};
}
