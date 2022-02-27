struct LuaState {
	lua_State* raw_state;
	sol::state_view state;

	LuaState();
	int reload(std::string script_name);
	void prepend_to_search_path(std::string directory);
	void script_dir(ScriptPath path);
	void script_file(ScriptPath path);
	void load_options();
	void update_entities(float dt);

	std::string scripts;
	std::string core;
	std::string dialogue;
	std::string layouts;
	std::string libs;
	std::string saves;
	std::string gstate; 
} Lua; // @firmament make this a global

void init_lua();
void init_scripts();
