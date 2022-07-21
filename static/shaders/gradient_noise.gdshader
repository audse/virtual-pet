shader_type canvas_item;
render_mode blend_mul;

varying vec2 vert;

uniform sampler2D noise;
uniform vec2 noise_size;
uniform vec2 origin = vec2(1, 0.5); // right center
uniform float weight = 0.0;
uniform float alpha = 1.0;
uniform bool flip_x = false;
uniform bool flip_y = false;

void vertex() {
	vert = VERTEX;
}

vec2 add_amount(vec2 vert_pos) {
	float x = mix(vert_pos.x / noise_size.x, weight, abs(origin.x));
	float y = mix(vert_pos.y / noise_size.y, weight, abs(origin.y));
	
	return vec2(x, y);
}

void fragment() {
    float noise_value = texture(noise, UV).x;
    COLOR = vec4(noise_value);
	
    vec2 amt = add_amount(vert);
	
	if (flip_x) {
		amt.x = 0.5 - amt.x;
	}
	if (flip_y) {
		amt.y = 0.5 - amt.y;
	}
	
	float a = amt.x + amt.y + (1.0 - alpha);
	
	COLOR.rgb += vec3(a);
}
