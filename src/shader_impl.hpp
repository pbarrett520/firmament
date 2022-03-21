void Shader::init(const char* vs_path, const char* fs_path, const char* name) {
	arr_init(&uniforms_set_this_call, MAX_UNIFORMS);
	
	const char* paths[] = {
		vs_path,
		fs_path
	};

	int success;

	unsigned int shader_program;
	shader_program = glCreateProgram();
	
	fox_for(ishader, 2) {
		// Read in shader data
		const char* path = paths[ishader];
		FILE *shader_source_file = fopen(path, "rb");
		if (!shader_source_file) {
			tdns_log.write("could not open shader file, file = %s", path);
		}

		fseek(shader_source_file, 0, SEEK_END);
		unsigned int fsize = ftell(shader_source_file);
		fseek(shader_source_file, 0, SEEK_SET);

		char* source = (char*)calloc(fsize + 1, sizeof(char));
		defer { free(source); };
		
		fread(source, fsize, 1, shader_source_file);
		source[fsize] = 0;
		fclose(shader_source_file);

		// Compile the shader
		unsigned int shader_kind = (ishader == 0) ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER;
		unsigned int shader = glCreateShader(shader_kind);

		glShaderSource(shader, 1, &source, NULL);

		glCompileShader(shader);

		glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
		if (!success) {
			glGetShaderInfoLog(shader, 512, NULL, compilation_status);
			tdns_log.write("shader compile error, err = %s", compilation_status);
		}
		glAttachShader(shader_program, shader);
	}
		
	// Link into a shader program
	glLinkProgram(shader_program);
	glGetShaderiv(shader_program, GL_COMPILE_STATUS, &success);
	if (!success) {
		glGetShaderInfoLog(shader_program, 512, NULL, compilation_status);
		tdns_log.write("shader compile error, err = %s", compilation_status);
	}

	// Push the data into the shader. If anything fails, the shader won't get
	// the new GL handles
	id = shader_program;
	glGetProgramiv(shader_program, GL_ACTIVE_UNIFORMS, (int*)&num_uniforms);

	strncpy(this->name, name, MAX_PATH_LEN);
	strncpy(this->vs_path, vs_path, MAX_PATH_LEN);
	strncpy(this->fs_path, fs_path, MAX_PATH_LEN);
}

unsigned int Shader::get_uniform_loc(const char* uniform) {
	// Shader failed to load properly. Don't spam the log.
	if (num_uniforms == 0) return -1;
	
	auto loc = glGetUniformLocation(id, uniform);
	if (loc == -1) {
		tdns_log.write("uniform does not exist: uniform = %s, shader = %s", uniform, this->name);
	}
	return loc;
}

void Shader::mark_uniform_set(const char* name) {
	fm_assert(uniforms_set_this_call.size < MAX_UNIFORMS);
	char (*arr) [MAX_UNIFORM_LEN] = arr_next(&uniforms_set_this_call);
	char* buffer = &(*arr)[0];
	strncpy(buffer, name, MAX_PATH_LEN);
	uniforms_set_this_call.size += 1;
	#if 0
	for (int32 i = 0; i < MAX_UNIFORMS; i++) {
		char* uniform = uniforms_set_this_call[i];
		if (!strlen(uniform)) strncpy(uniform, name, MAX_PATH_LEN);
	}
	#endif
}

void Shader::set_vec4(const char* name, glm::vec4 vec) {
	glUniform4f(get_uniform_loc(name), vec.x, vec.y, vec.z, vec.w);
	mark_uniform_set(name);
}
void Shader::set_vec3(const char* name, glm::vec3 vec) {
	glUniform3f(get_uniform_loc(name), vec.x, vec.y, vec.z);
	mark_uniform_set(name);
}
void Shader::set_vec2(const char* name, glm::vec2 vec) {
	glUniform2f(get_uniform_loc(name), vec.x, vec.y);
	mark_uniform_set(name);
}
void Shader::set_mat3(const char* name, glm::mat3 mat) {
	glUniformMatrix3fv(get_uniform_loc(name), 1, GL_FALSE, glm::value_ptr(mat));
	mark_uniform_set(name);
}
void Shader::set_mat4(const char* name, glm::mat4 mat) {
	glUniformMatrix4fv(get_uniform_loc(name), 1, GL_FALSE, glm::value_ptr(mat));
	mark_uniform_set(name);
}
void Shader::set_int(const char* name, GLint val) {
	glUniform1i(get_uniform_loc(name), val);
	mark_uniform_set(name);
}
void Shader::set_float(const char* name, GLfloat val) {
	glUniform1f(get_uniform_loc(name), val);
	mark_uniform_set(name);
}

void Shader::begin() {
	if (Shader::active != -1) {
		tdns_log.write("tried to begin a shader when another was active, shader = %s", name);
		return;
	}
	
	glUseProgram(id);
	Shader::active = id;
	arr_clear(&uniforms_set_this_call);
}

void Shader::check() {
	if (uniforms_set_this_call.size != num_uniforms) {
		tdns_log.write("missing uniforms, shader = %s", name);
		return;
	}
	if (Shader::active != (int)id) {
		tdns_log.write("shader was not set before checked, shader = %s", name);
		return;
	}
}

void Shader::end() {
	arr_clear(&uniforms_set_this_call);
	Shader::active = -1;
}

void init_shaders() {
	auto& shaders = get_shader_manager();

	char vs_path [MAX_PATH_LEN] = {0};
	char fs_path [MAX_PATH_LEN] = {0};

	fm_shader("textured.vs", vs_path, MAX_PATH_LEN);
	fm_shader("textured.fs", fs_path, MAX_PATH_LEN);
	shaders.add(vs_path, fs_path, "textured");
		
	fm_shader("solid.vs", vs_path, MAX_PATH_LEN);
	fm_shader("solid.fs", fs_path, MAX_PATH_LEN);
	shaders.add(vs_path, fs_path, "solid");
	
	fm_shader("text.vs", vs_path, MAX_PATH_LEN);
	fm_shader("text.fs", fs_path, MAX_PATH_LEN);
	shaders.add(vs_path, fs_path, "text");
}

void ShaderManager::add(const char* vs_path, const char* fs_path, const char* name) {
	Shader shader;
	shader.init(vs_path, fs_path, name);
	shaders[name] = shader;

	file_watcher.watch(vs_path, [this](const char* vs_path){
		for (auto& [name, shader] : shaders) {
			if (!strcmp(shader.vs_path, vs_path)) {
				tdns_log.write("reloading shader, shader = %s", name);
				shader.init(shader.vs_path, shader.fs_path, shader.name);
			}
		}
	});
	
	file_watcher.watch(fs_path, [this](const char* fs_path){
		for (auto& [name, shader] : shaders) {
			if (!strcmp(shader.fs_path, fs_path)) {
				tdns_log.write("reloading shader, shader = %s", name);
				shader.init(shader.vs_path, shader.fs_path, shader.name);
			}
		}
	});
}

Shader* ShaderManager::get(const char* name) {
	auto it = shaders.find(name);
	if (it == shaders.end()) {
		tdns_log.write("missing shader, shader = %s",  name);
		return nullptr;
	}

	return &(it->second);
}

ShaderManager& get_shader_manager() {
	static ShaderManager manager;
	return manager;
}
