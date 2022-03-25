void init_fonts() {
	FT_Library fm_freetype;
	
	if (FT_Init_FreeType(&fm_freetype)) {
		tdns_log.write("Failed to initialize FreeType");
		exit(0);
	}

	
	FT_Face face = nullptr;
	if (FT_New_Face(fm_freetype, fm_gm_font_path, 0, &face)) {
		tdns_log.write(Log_Flags::Console,
					  "failed to load font, font = %s",
					  fm_gm_font_path);
		return;
	}
	
	int32 ft_font_size = fm_gm_font_size << 6; // Scaled to FT's units, where 26.6 units = 1 pixel
	FT_Set_Char_Size(face, 0, ft_font_size, 96, 96); 
	
	int num_glyphs = 128;

	FontInfo font;
	font.name = fm_gm_font;
	font.glyphs = arr_view(&glyph_infos, glyph_infos.size, num_glyphs);
	font.max_advance = {
		magnitude_gl_from_screen(screen_x_from_px((float32)face->max_advance_width) / 64),
		magnitude_gl_from_screen(screen_y_from_px((float32)face->max_advance_height / 64)),
	};
	font.ascender = magnitude_gl_from_screen(screen_y_from_px((float32)face->ascender / 64));
	font.descender = magnitude_gl_from_screen(screen_y_from_px((float32)face->descender / 64));
	arr_push(&font_infos, font);
	
	// Image buffer 
	int32 font_height_px = face->size->metrics.height >> 6;
	int32 glyphs_per_row = static_cast<int32>(ceil(sqrt(128)));
	
	int tex_height = font_height_px * glyphs_per_row;
	int tex_width = tex_height;
	char* buffer = (char*)calloc(tex_width * tex_height, sizeof(char));
	defer { free(buffer); };

	// Read each character's bitmap into the image buffer
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

		GlyphInfo glyph;
		glyph.size = {
			magnitude_gl_from_screen(screen_x_from_px((float32)face->glyph->bitmap.width)),
			magnitude_gl_from_screen(screen_y_from_px((float32)face->glyph->bitmap.rows)),
		};
		glyph.bearing = {
			magnitude_gl_from_screen(screen_x_from_px(face->glyph->bitmap_left)),
			magnitude_gl_from_screen(screen_y_from_px(face->glyph->bitmap_top)),
		};
		glyph.advance = {
			magnitude_gl_from_screen(screen_x_from_px((float32)face->glyph->advance.x / 64)),
			magnitude_gl_from_screen(screen_y_from_px((float32)face->glyph->advance.y / 64)),
		};

		// Build the mesh, put the data the GPU needs in the appropriate buffer
		Mesh* mesh = arr_push(&mesh_infos);

		mesh->count = 6;
		
		gl_unit gl_left = -1 + glyph.bearing.x;
		gl_unit gl_right = gl_left + glyph.size.x;
		gl_unit gl_top = 1 + glyph.bearing.y;
		gl_unit gl_bottom = gl_top - glyph.size.y;
		Vector2 vertices[6] = {
				{ gl_left,  gl_top },
				{ gl_left,  gl_bottom },
				{ gl_right, gl_bottom },
			
				{ gl_left,  gl_top },
				{ gl_right, gl_bottom },
				{ gl_right, gl_top },
		};
		mesh->verts = arr_push(&vx_data, vertices, 6);

		float tc_left = point.x / tex_width;
		float tc_right = (point.x + face->glyph->bitmap.width) / tex_width;
		float tc_top = 1 - (point.y / tex_height); // Y-axis coordinates are flipped, because we flip the texture
		float tc_bottom = 1 - ((point.y + face->glyph->bitmap.rows) / tex_height);
		Vector2 tex_coords[6] = {
				{ tc_left,  tc_top },
				{ tc_left,  tc_bottom },
				{ tc_right, tc_bottom },
			
				{ tc_left,  tc_top },
				{ tc_right, tc_bottom },
				{ tc_right, tc_top },
		};
		mesh->tex_coords = arr_push(&tc_data, tex_coords, 6);

		glyph.mesh = mesh;

		arr_push(&glyph_infos, glyph);
		// Advance the point horizontally for the next character
		point.x += bitmap->width + 1;
	}


	char* tmp = (char*)calloc(tex_width, sizeof(char));
	for (int32 i = 0; i != tex_height / 2; i++) {
		char* top = buffer + (i * tex_width); // first element of top row
		char* btm = buffer + ((tex_height - i - 1) * tex_width); // first element of bottom row
		memcpy(tmp, top, tex_width);
		memcpy(top, btm, tex_width);
		memcpy(btm, tmp, tex_width);
	}

	//stbi_write_png(fm_atlas_gm, tex_width, tex_height, 1, buffer, tex_width);

	auto& render_engine = get_render_engine();
	glGenTextures(1, &render_engine.texture);
	glBindTexture(GL_TEXTURE_2D, render_engine.texture);
	glTexImage2D(GL_TEXTURE_2D,0, GL_RED, tex_width, tex_height, 0, GL_RED, GL_UNSIGNED_BYTE, buffer);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	FT_Done_Face(face);
	FT_Done_FreeType(fm_freetype);
}
