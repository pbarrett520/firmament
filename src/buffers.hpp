// Buffers: chunks of contiguous memory that we push stuff to
#define VERT_BUFFER_SIZE 8192
Array<Vector2>        vertex_buffer;
#define TC_BUFFER_SIZE VERT_BUFFER_SIZE
Array<Vector2>        tc_buffer;
#define COLOR_BUFFER_SIZE VERT_BUFFER_SIZE
Array<Vector4>        color_buffer;
#define MESH_BUFFER_SIZE 1024
Array<Mesh>           meshes;
#define TEXT_BUFFER_SIZE 4096
Array<TextRenderInfo> text_buffer;
#define EFFECT_BUFFER_SIZE 8192
Array<TextEffect>     effect_buffer;

// Infos: chunks of contiguous memory that are initialized and then static
#define GLYPH_INFO_SIZE 256
Array<GlyphInfo> glyph_infos;
#define VX_INFO_SIZE 8192
Array<Vector2>   vx_infos;
#define TC_INFO_SIZE VX_INFO_SIZE
Array<Vector2>   tc_infos;

void init_buffers() {
	arr_init(&vertex_buffer, VERT_BUFFER_SIZE);
	arr_init(&tc_buffer,     TC_BUFFER_SIZE);
	arr_init(&color_buffer,  COLOR_BUFFER_SIZE);
	arr_init(&meshes,        MESH_BUFFER_SIZE);
	arr_init(&text_buffer,   TEXT_BUFFER_SIZE);
	arr_init(&effect_buffer, EFFECT_BUFFER_SIZE);
	
	arr_init(&glyph_infos,   GLYPH_INFO_SIZE);
	arr_init(&vx_infos,      VX_INFO_SIZE);
	arr_init(&tc_infos,      TC_INFO_SIZE);
}

