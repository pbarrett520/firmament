// Library includes
#include "glad/glad.h"
#include "GLFW/glfw3.h"

#define GLM_ENABLE_EXPERIMENTAL
#include "glm/glm.hpp"
#include "glm/gtx/string_cast.hpp"
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"
#define STB_RECT_PACK_IMPLEMENTATION
#include "stb/stb_rect_pack.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"
#define STB_TRUETYPE_IMPLEMENTATION
#include "stb/stb_truetype.h"

extern "C" {
  #include "freetype/ft2build.h"
  #include "freetype/freetype.h"
  #include "freetype/ftsizes.h"
}

#include "lua/lua.hpp"


#include "sol/sol.hpp"

#define IMGUI_DEFINE_MATH_OPERATORS
#include "imgui/imgui.h"
#include "imgui/imgui_internal.h"
#include "imgui/imgui_impl_glfw_gl3.hpp"
#include "imgui/imfilebrowser.h"

// STL
#include <algorithm>
#include <array>
#include <chrono>
#include <map>
#include <math.h>
#include <memory>
#include <regex>
#include <stdlib.h>
#include <stdarg.h>
#include <unordered_set>
#include <unordered_map>
#include <vector>
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <map>
#include <queue>
#include <string>
#include <sstream>
#include <cmath>
#include <typeindex>
#include <optional>
#include <iomanip>
#include <limits>
#include <typeinfo>
#include <filesystem>
#include <numeric>
#include <random>
using namespace std::filesystem;

