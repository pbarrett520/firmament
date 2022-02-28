LuaState::LuaState() :
	raw_state(luaL_newstate()),
	state(raw_state)
{}

void LuaState::prepend_to_search_path(std::string directory) {
	directory = absolute_path(directory);
	directory += "/?.lua";
	normalize_path(directory);
	tdns_log.write("Adding directory to Lua include path: " + directory, Log_Flags::File);
		
	// NEW_ITEM;old_path
	std::string old_path = Lua.state["package"]["path"];
	std::string new_path = directory + ";" + old_path;
	state["package"]["path"] = new_path;
}

void LuaState::script_file(ScriptPath path) {
	tdns_log.write("Loaded script: " + path.path, Log_Flags::File);
	auto result = state.script_file(path.path, [](auto, auto pfr) {
		return pfr;
	});

	if (!result.valid()) {
		sol::error error = result;
		tdns_log.write("Failed to script file: " + path.path);
		tdns_log.write(error.what());
	}

	file_watcher.watch(path.path, [this, path](){
		tdns_log.write("@reload_script: " + path.path);
		this->script_file(path);
	});
}

void LuaState::script_dir(ScriptPath path) {
	file_watcher.watch_dir(path.path, [&](auto new_script) {
		tdns_log.write("@load_new_script: " + new_script);
		this->script_file(new_script);
	});
	
	for (auto it = directory_iterator(path.path); it != directory_iterator(); it++) {
		std::string next_path = it->path().string();
		normalize_path(next_path);
		// Make sure the path is a TDS file that has not been run
		if (is_regular_file(it->status())) {
			if (is_lua(next_path)) {
				script_file(ScriptPath(next_path));
			}
		}
		else if (is_directory(it->status())) {
			script_dir(next_path);
		}
	}
}

void LuaState::load_options() {
	sol::table options = state["tdengine"]["options"];
	
	g_dialogue_font = options["dialogue_font"];
	g_dialogue_font_path = absolute_path(path_join({"asset", "fonts", g_dialogue_font}));
	g_dialogue_font_path = g_dialogue_font_path + ".ttf";
	g_dialogue_font_size = options["dialogue_font_size"];

	g_editor_font = options["editor_font"];
	g_editor_font_path = absolute_path(path_join({"asset", "fonts", g_editor_font}));
	g_editor_font_path = g_editor_font_path + ".ttf";
	g_editor_font_size = options["editor_font_size"];
}

void LuaState::update_entities(float dt) {
	sol::protected_function update = state["tdengine"]["update_entities"];
	auto result = update(dt);
	if (!result.valid()) {
		sol::error err = result;
		tdns_log.write(err.what());
	}
}

// Basic Lua bootstrapping. Don't load any game scripts here. This is called before
// we load all the backend systems, because this populates options that those systems
// might use. 
void init_lua() {
	auto& lua_manager = Lua;
	
	lua_manager.state.open_libraries(
        sol::lib::base,
        sol::lib::bit32,
		sol::lib::debug,
		sol::lib::io,
		sol::lib::jit,
		sol::lib::math,
		sol::lib::os,
		sol::lib::package,
		sol::lib::string,
		sol::lib::table);

	// Give those paths to Lua
	lua_manager.prepend_to_search_path(fm_scripts);
	lua_manager.prepend_to_search_path(fm_libs);
	lua_manager.prepend_to_search_path(fm_core);
	lua_manager.prepend_to_search_path(fm_saves);

	// Bind all C functions
	LoadImguiBindings();
	register_lua_api();

	// Then, script the base packages you need
	lua_manager.script_dir(RelativePath("libs"));
	lua_manager.script_dir(RelativePath("core"));

	// @firmament break out error code and load it first
	sol::protected_function error_handler = lua_manager.state["tdengine"]["handle_error"];
	sol::protected_function::set_default_handler(error_handler);

	lua_manager.load_options();
}

void init_scripts() {
	auto& lua_manager = Lua;

	// Basic initialization of stuff that needs to exist in Lua before we load
	// all the actual game scripts
	lua_manager.state.script("tdengine.initialize()");

	lua_manager.script_dir(RelativePath("entities"));

	// Once everything is set up, we can start up the editor
	lua_manager.state.script("tdengine.load_editor()");
}

