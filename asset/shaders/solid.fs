#version 330 core
out vec4 frag_color;

in vec4 fs_color;

void main() {
    frag_color = fs_color;
} 
