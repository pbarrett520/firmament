struct LuaState {
	lua_State* raw_state;
	sol::state_view state;

	LuaState();
	int reload(std::string script_name);
	void prepend_to_search_path(std::string directory);
	void script_dir(const char* path);
	void script_file(const char* path);
	void load_options();
	void update_entities(float dt);
} Lua; // @firmament make this a global

void init_lua();
void init_scripts();
void update_engine_stats_lua();
