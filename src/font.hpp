struct Mesh;
struct GlyphInfo {
	Mesh* mesh = nullptr;
	Vector2 size;
	Vector2 bearing;
	Vector2 advance;
};

struct FontInfo {
	ArrayView<GlyphInfo> glyphs;
	const char* name;
	Vector2 max_advance;
};

struct Font {
	uint advance(char c);
	
	glm::ivec2 px_largest;
	std::string name;
	std::string path;
	int size;
};

std::map<std::string, Font> g_fonts;

void init_fonts();
