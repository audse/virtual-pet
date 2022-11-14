shader_type spatial;

#include "res://static/shaders/material_settings.gdshaderinc"
#define INCLUDE_FRAGMENT

group_uniforms Distortion;
uniform vec3 max_distort = vec3(0.1);
uniform float steps: hint_range(0.0, 20.0, 1.0);
uniform int seed: hint_range(1, 128);

float hash (vec3 p) {
	return fract(sin(dot(p * 17.17, vec3(14.91, 67.31, 89.21))) * 4791.9511 * float(seed));
}

varying vec3 vert;

void vertex () {
	UV = get_uv(UV);
	vec3 prev_step = round((VERTEX - 1.5 / steps) * steps) / steps;
	vec3 next_step = round((VERTEX + 1.5 / steps) * steps) / steps;
	float prev_height = hash(prev_step);
	float next_height = hash(next_step);
	
	vec3 height = smoothstep(prev_height, next_height, VERTEX);
	
	VERTEX.xyz += (height * max_distort) - (max_distort / 4.0);
	COLOR.xyz = vec3(height);
	vert = VERTEX;
}