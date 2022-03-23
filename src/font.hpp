struct GlyphInfo {
	Mesh* mesh = nullptr;
	Vector2 size;
	Vector2 bearing;
	Vector2 advance;
};

struct Font {
	uint advance(char c);
	
	glm::ivec2 px_largest;
	std::string name;
	std::string path;
	int size;
};

FT_Library freetype;
GLuint font_vao, font_vert_buffer;
std::map<std::string, Font> g_fonts;

void init_fonts();
