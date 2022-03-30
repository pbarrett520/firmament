#include "libs.hpp"

#include "machine_conf.hpp"
#include "types.hpp"
#include "options.hpp"
#include "paths.hpp"
#include "error.hpp"
#include "log.hpp"
#include "utils.hpp"
#include "input.hpp"
#include "transform.hpp"
#include "console.hpp"
#include "lua.hpp"
#include "font.hpp"
#include "draw.hpp"
#include "effects.hpp"
#include "text.hpp"
#include "shader.hpp"
#include "imgui/imgui_lua_bindings.hpp"
#include "api.hpp"
#include "buffers.hpp"

#include "api_impl.hpp"
#include "console_impl.hpp"
#include "draw_impl.hpp"
#include "effects_impl.hpp"
#include "font_impl.hpp"
#include "input_impl.hpp"
#include "lua_impl.hpp"
#include "shader_impl.hpp"
#include "text_impl.hpp"
#include "transform_impl.hpp"
#include "utils_impl.hpp"

int main() {
	auto& input_manager  = get_input_manager();
	auto& shader_manager = get_shader_manager();
	auto& render_engine  = get_render_engine();

	init_log();
	init_buffers();
	init_lua();
	init_glfw();
	init_imgui();
	init_shaders();
	init_gl();
	init_text_boxes();
	init_scripts();
	init_fonts();

	srand(time(NULL));

	while(!glfwWindowShouldClose(g_window)) {
		double frame_start_time = glfwGetTime();
		
		if (send_kill_signal) return 0;

		file_watcher.update();

		// After this, inputs are set for the frame
		input_manager.begin_frame();

		// Do a couple utility things we do each frame
		load_imgui_layout();
		update_engine_stats_lua();
		mtb_update_scroll(&main_box, seconds_per_update);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		// After this, all ImGui calls are live. Anything before this is ignored.
		ImGui_ImplGlfwGL3_NewFrame();
		
		if (show_imgui_demo) ImGui::ShowDemoWindow();
		if (show_console) console.Draw("firmament");

		// Run scripts
		Lua.update_entities(seconds_per_update);
		
		// Render 
		render_engine.render(seconds_per_update);

		ImGuiWrapper::EndAndRecover();
		ImGui::Render();
		ImGui_ImplGlfwGL3_RenderDrawData(ImGui::GetDrawData());
		glfwSwapBuffers(g_window);

		// Clean up the frame
		input_manager.end_frame();

		framerate = 1.f / (glfwGetTime() - frame_start_time);
		Lua.state["tdengine"]["framerate"] = framerate;

		// Lock the framerate
		while (glfwGetTime() - frame_start_time < seconds_per_update) {}
	}

	return 0;
}
