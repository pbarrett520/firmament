#version 330 core
layout (location = 0) in vec2 pos;
layout (location = 1) in vec4 color;

out vec4 fs_color;

void main() {
	gl_Position = vec4(pos, 1.f, 1.f);

	fs_color = color;
}	
