#include "libs.hpp"

#include "machine_conf.hpp"
#include "log.hpp"
#include "utils.hpp"
#include "input.hpp"
#include "transform.hpp"
#include "console.hpp"
#include "lua.hpp"
#include "font.hpp"
#include "draw.hpp"
#include "shader.hpp"
#include "imgui/imgui_lua_bindings.hpp"
#include "api.hpp"

#include "api_impl.hpp"
#include "console_impl.hpp"
#include "draw_impl.hpp"
#include "font_impl.hpp"
#include "lua_impl.hpp"
#include "shader_impl.hpp"
#include "transform_impl.hpp"

int main() {
	tdns_log.init();

	auto& input_manager      = get_input_manager();
	auto& shader_manager     = get_shader_manager();
	auto& render_engine      = get_render_engine();

	init_lua();
	
	EXIT_IF_ERROR(init_glfw());
	init_imgui();

	render_engine.init();

	init_shaders();
	init_fonts();
	init_gl();
	init_scripts();

	// MAIN LOOP
	while(!glfwWindowShouldClose(g_window)) {
		double frame_start_time = glfwGetTime();
		
		if (send_kill_signal) return 0;

		file_watcher.update();
		
		glfwPollEvents();

		fill_imgui_input();
		load_imgui_layout();

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		ImGui_ImplGlfwGL3_NewFrame();
		
		if (show_imgui_demo) ImGui::ShowDemoWindow();
		if (show_console) console.Draw("tdengine");

		// Run scripts
		Lua.update_entities(seconds_per_update);
		
		// Render 
		render_engine.render(seconds_per_update);
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
