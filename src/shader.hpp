#define MAX_UNIFORMS 16
#define MAX_UNIFORM_LEN 32

struct Shader {
	char name    [MAX_PATH_LEN] = {0};
	char vs_path [MAX_PATH_LEN] = {0};
	char fs_path [MAX_PATH_LEN] = {0};
	uint id = 0;
	uint num_uniforms = 0;
	Array<char[MAX_UNIFORM_LEN]> uniforms_set_this_call;
	
	static int active;
	static char compilation_status[512];

	void init(const char* vs_path, const char* fs_path, const char* name);
	unsigned int get_uniform_loc(const char* name);
	bool was_uniform_set(const char* name);
	void mark_uniform_set(const char* name);

	void set_vec4(const char* name, glm::vec4 vec);
	void set_vec3(const char* name, glm::vec3 vec);
	void set_vec2(const char* name, glm::vec2 vec);
	void set_mat3(const char* name, glm::mat3 mat);
	void set_mat4(const char* name, glm::mat4 mat);
	void set_int(const char* name, GLint val);
	void set_float(const char* name, GLfloat val);

	void begin();
	void check();
	void end();
};
int Shader::active = -1;
char Shader::compilation_status[512];

void init_shaders();

struct cmp_str {
   bool operator()(char const *a, char const *b) const {
      return strcmp(a, b) < 0;
   }
};

struct ShaderManager {
	std::map<const char*, Shader, cmp_str> shaders;
	
	void add(const char* vs_path, const char* fs_path, const char* name);
	Shader* get(const char* name);
};
ShaderManager& get_shader_manager();	
