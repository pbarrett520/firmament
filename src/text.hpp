// Various areas that we write text to
struct MainTextBox {
	Mesh* mesh;
	Vector2 pos;
	Vector2 dim;
	Vector2 pad;
	Vector4 dbg_color;

	int32 line_scroll = 0;
	
	// Smooth scrolling
	float32 last_frame_scroll = 0.f;
	float32 scroll_cur = 0.f;
	float32 scroll_lerpstart = 0.f;
	float32 scroll_tgt = 0.f;
	float32 lerp_tot = 1.f;
	float32 lerp_acc = 0.f;
	int32 frames_still = 0;
};
MainTextBox main_box;
void mtb_update_scroll(MainTextBox* mtb, float dt);
void mtb_update_scroll_smooth(MainTextBox* mtb, float dt);

struct ChoiceBox {
	Mesh* mesh;
	Vector2 pos;
	Vector2 dim;
	Vector2 pad;
	Vector4 dbg_color;
};
ChoiceBox choice_box;

// Request for drawing text to the main text box.
//
// Line breaks are to be interpreted as such: Every substring in the text of the form
// s[lb[i]], s[lb[i+1]] should be rendered on its own line. In particular, this means that
// 0 and text.size - 1 are marked as line breaks
#define MAX_TEXT_LEN 1024
#define MAX_LINE_BREAKS 16
struct TextRenderInfo {
	char              text    [MAX_TEXT_LEN]    = { 0 };
	int32             lbreaks [MAX_LINE_BREAKS] = { 0 };
	int32             count_lb                  = 0;
	Array<TextEffect> effects                   = { 0 };
};

// Used for smoothing over advancing the point when rendering characters
struct TextRenderContext {
	TextRenderInfo* info  = nullptr;
	FontInfo* font        = nullptr;

	Vector2 point;
	int32 skipped             = 0;
	int32 max_lines           = 0;
	int32 count_lines_written = 0;
	bool  is_chunk_done       = false;
	int32 ib                  = 0;
	int32 ilb                 = 0;
};
void text_ctx_init(TextRenderContext* ctx, FontInfo* font);
void text_ctx_chunk(TextRenderContext* ctx, TextRenderInfo* chunk);
bool text_ctx_chunkdone(TextRenderContext* ctx);
bool text_ctx_full(TextRenderContext* ctx);
ArrayView<char> text_ctx_readline(TextRenderContext* ctx);
void  text_ctx_nextline(TextRenderContext* ctx);
void text_ctx_advance(TextRenderContext* ctx, GlyphInfo* glyph);
float32 text_ctx_scroll(TextRenderContext* ctx);

void init_text_boxes();
