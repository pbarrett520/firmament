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

#define MAX_CHOICE_LEN 256
struct ChoiceInfo {
	char text [MAX_CHOICE_LEN] = { 0 };
};

#define MAX_CHOICES 8
struct ChoiceBox {
	Mesh* mesh;
	Vector2 pos;
	Vector2 dim;
	Vector2 pad;
	Vector4 dbg_color;

	int32 hovered = 0;
};
ChoiceBox choice_box;
void cbx_init(ChoiceBox* cbx);
void cbx_add(ChoiceBox* cbx, ChoiceInfo choice);
void cbx_clear(ChoiceBox* cbx);

struct ChoiceRenderContext {
	FontInfo* font = nullptr;
	Vector2 point;
};
void choice_ctx_init(ChoiceRenderContext* ctx, FontInfo* font);
void choice_ctx_advance(ChoiceRenderContext* ctx, GlyphInfo* glyph);
void choice_ctx_nextline(ChoiceRenderContext* ctx);


// Request for drawing text to the main text box.
//
// Line breaks are to be interpreted as such: Every substring in the text of the form
// s[lb[i]], s[lb[i+1]] should be rendered on its own line. In particular, this means that
// 0 and text.size - 1 are marked as line breaks
#define MAX_TEXT_LEN 1024
#define MAX_SPEAKER_LEN 32
#define MAX_LINE_BREAKS 16
struct TextRenderInfo {
	char              text      [MAX_TEXT_LEN]    = { 0 };
	int32             lbreaks   [MAX_LINE_BREAKS] = { 0 };
	int32             count_lb                    = 0;
	Array<TextEffect> effects                     = { 0 };
	char              speaker   [32]              = { 0 };
	int32             speaker_len                 = 0;
	Vector4           speaker_color               = { 0 };
};

// Algorithm: Iterate through requests in LIFO order, so that the newest requests are rendered
// first. Then, iterate over their line breaks, starting from the last line. Iterate the line,
// and move to the line above. Move to the next request.
struct TextRenderContext {
	TextRenderInfo* info  = nullptr;
	FontInfo* font        = nullptr;

	Vector2 point;
	int32 skipped             = 0;
	int32 max_lines           = 0;
	int32 count_lines_written = 0;
	bool  is_chunk_done       = false;
	int32 ib_low              = 0;
	int32 ib_hi               = 0;
	int32 count_chunk_vx      = 0;
};
void text_ctx_init(TextRenderContext* ctx, FontInfo* font);
void text_ctx_chunk(TextRenderContext* ctx, TextRenderInfo* chunk);
bool text_ctx_chunkdone(TextRenderContext* ctx);
bool text_ctx_full(TextRenderContext* ctx);
bool text_ctx_islast(TextRenderContext* ctx);
ArrayView<char> text_ctx_readline(TextRenderContext* ctx);
void text_ctx_nextline(TextRenderContext* ctx);
void text_ctx_render(TextRenderContext* ctx, char c);
void text_ctx_advance(TextRenderContext* ctx, char c);
float32 text_ctx_scroll(TextRenderContext* ctx);

void init_text_boxes();
