shader_type spatial;

uniform sampler2D noise;
uniform sampler2D island_shape;
uniform vec2 size = vec2(1.0);

void vertex () {
	vec2 relative_vert = size / VERTEX.xz;
	vec4 noise_color = texture(noise, relative_vert);
	vec4 island_color = texture(island_shape, relative_vert);
	vec4 height = noise_color - island_color;
	
}