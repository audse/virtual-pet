shader_type canvas_item;

uniform vec2 center_offset = vec2(0.0);
uniform vec4 blob_color: source_color;
uniform vec2 blob_1_position = vec2(0.9, 0.55);
uniform vec2 blob_2_position = vec2(0.2, 0.45);
uniform sampler2D noise;
uniform float speed: hint_range(1.0, 10.0, 1.0);

uniform bool show_dots = false;
uniform vec2 dots_position = vec2(0.5, 0.5);

varying float noise_distortion;

float get_noise_distortion(vec2 uv) {
	float speed_value = 10.0 - speed;
	vec2 uv_offset = vec2(0.0, (sin(TIME / speed_value) * cos(TIME / speed_value)));
	return cos(texture(noise, uv + uv_offset / 1.5).r);
}


void fragment() {
	noise_distortion = get_noise_distortion(UV);
	
	vec2 dot_1_pos = mix(dots_position, vec2(0.5, 0.5), 0.4);
	vec2 dot_2_pos = mix(dots_position, vec2(0.5, 0.5), 0.15);
	
	vec2 iResolution = vec2(1.0);
	
    float max_size = max(iResolution.x, iResolution.y);
    
    vec2 center = iResolution / max_size * mix(vec2(0.5), vec2(1.0) - dots_position, 0.175) + center_offset;
	
    float distance_from_center = pow(distance(center, UV) * 9.0, 2);
    float distance_from_blob_1 = distance(blob_1_position / max_size, UV);
	float distance_from_blob_2 = distance(blob_2_position / max_size, UV);
	float color = distance_from_center * distance_from_blob_1 * distance_from_blob_2;
	
	color *= noise_distortion;
	
	COLOR = color < 1.25 ? blob_color / 2.0 : vec4(0.0);
	COLOR = color < 1.0 ? blob_color : COLOR;
	
	if (show_dots) {
		float distance_from_dot_1 = pow(distance(dot_1_pos, UV) * noise_distortion, 2);
		float distance_from_dot_2 = pow(distance(dot_2_pos, UV) * noise_distortion, 2);

		COLOR = distance_from_dot_1 < 0.0015 ? blob_color : (distance_from_dot_1 < 0.002 ? max(COLOR, blob_color / 2.0) : COLOR);
		COLOR = distance_from_dot_2 < 0.00025 ? blob_color : (distance_from_dot_2 < 0.0004 ? max(COLOR, blob_color / 2.0) : COLOR);
	}
}
