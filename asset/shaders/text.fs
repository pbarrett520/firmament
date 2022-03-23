#version 330 core
out vec4 frag_color;

in vec2 fs_tex_coord;
in vec4 fs_color;

uniform sampler2D sampler;

void main()
{
    // Textures are stored in just the red component -- really just a grayscale value
    vec4 sampled = vec4(1.f, 1.f, 1.f, texture(sampler, fs_tex_coord).r);

    // Scale our color by the grayness
    //frag_color = vec4(fs_color.r, fs_color.g, 0.f, 1.f) * sampled;
    frag_color = fs_color * sampled;
} 
