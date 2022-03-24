// Buffers: chunks of contiguous memory that we push stuff to
#define VERT_BUFFER_SIZE 1048576
Array<Vector2>        vx_buffer;
#define TC_BUFFER_SIZE VERT_BUFFER_SIZE
Array<Vector2>        tc_buffer;
#define COLOR_BUFFER_SIZE VERT_BUFFER_SIZE
Array<Vector4>        cr_buffer;
#define TEXT_BUFFER_SIZE 4096
Array<TextRenderInfo> text_buffer;
#define EFFECT_BUFFER_SIZE 8192
Array<TextEffect>     effect_buffer;

// Infos: chunks of contiguous memory that are initialized and then static
#define MESH_INFO_SIZE 1024
Array<Mesh>      mesh_infos;
#define GLYPH_INFO_SIZE 256
Array<GlyphInfo> glyph_infos;
#define VX_INFO_SIZE 8192
Array<Vector2>   vx_data;
#define TC_INFO_SIZE VX_INFO_SIZE
Array<Vector2>   tc_data;

void init_buffers() {
	arr_init(&vx_buffer,     VERT_BUFFER_SIZE);
	arr_init(&tc_buffer,     TC_BUFFER_SIZE);
	arr_init(&cr_buffer,     COLOR_BUFFER_SIZE);
	arr_init(&text_buffer,   TEXT_BUFFER_SIZE);
	arr_init(&effect_buffer, EFFECT_BUFFER_SIZE);
	
	arr_init(&mesh_infos,    MESH_INFO_SIZE);
	arr_init(&glyph_infos,   GLYPH_INFO_SIZE);
	arr_init(&vx_data,       VX_INFO_SIZE);
	arr_init(&tc_data,       TC_INFO_SIZE);
}

