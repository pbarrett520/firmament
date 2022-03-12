#define _fm_root2        _fm_root    "/"
#define _fm_log          _fm_root    "/" "log.txt"
#define _fm_source       _fm_root    "/" "src"
#define _fm_scripts      _fm_source  "/" "scripts"
#define _fm_core         _fm_scripts "/" "core"
#define _fm_entities     _fm_scripts "/" "entities"
#define _fm_components   _fm_scripts "/" "components"
#define _fm_dialogue     _fm_scripts "/" "dialogue"
#define _fm_layouts      _fm_scripts "/" "layouts"
#define _fm_libs         _fm_scripts "/" "libs"
#define _fm_saves        _fm_scripts "/" "saves"
#define _fm_state        _fm_scripts "/" "state"
#define _fm_bootstrap    _fm_core    "/" "bootstrap.lua"
#define _fm_assets       _fm_root    "/" "asset"
#define _fm_fonts        _fm_assets  "/" "fonts"
#define _fm_gm_font_path _fm_fonts   "/" _fm_gm_font ".ttf"
#define _fm_ed_font_path _fm_fonts   "/" _fm_ed_font ".ttf"

#define _fm_layout     _fm_layouts "/" "%s.ini"
#define fm_layout(layout, buf, n) snprintf(buf, n, _fm_layout, layout)

const char* fm_root = _fm_root;
const char* fm_root2 = _fm_root2;
const char* fm_log = _fm_log;
const char* fm_source = _fm_source;
const char* fm_scripts = _fm_scripts;
const char* fm_core = _fm_core;
const char* fm_entities = _fm_entities;
const char* fm_components = _fm_components;
const char* fm_dialogue = _fm_dialogue;
const char* fm_layouts = _fm_layouts;
const char* fm_libs = _fm_libs;
const char* fm_saves = _fm_saves;
const char* fm_state = _fm_state;
const char* fm_bootstrap = _fm_bootstrap;
const char* fm_assets = _fm_assets;
const char* fm_fonts = _fm_fonts;
const char* fm_gm_font_path = _fm_gm_font_path;
const char* fm_ed_font_path = _fm_ed_font_path;
