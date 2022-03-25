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
	float32 ascender;
	float32 descender;
};

void init_fonts();
