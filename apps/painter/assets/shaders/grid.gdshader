shader_type canvas_item;

uniform float grid_x = 50.0;
uniform float grid_y = 50.0;
uniform float dot_size = 2.0;

uniform float minigrid_x = -1.0;
uniform float minigrid_y = -1.0;

uniform vec4 background: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 dots: source_color = vec4(0.5, 0.5, 0.5, 1.0);

varying vec2 vert;

void vertex() {
	vert = VERTEX;
}

bool fuzzy_remainder(float x, float y, float size) {
	float remainder = round(x / y);
	float target = remainder * y;
	return abs(target - x) < size;
}

void fragment() {
	bool x_remainder = fuzzy_remainder(vert.x, grid_x, dot_size);
	bool y_remainder = fuzzy_remainder(vert.y, grid_y, dot_size);
	
	if (x_remainder && y_remainder) {
		COLOR = dots;
	} else {
		COLOR = background;
	}
	
	if (minigrid_x > 0.0 && minigrid_y > 0.0) {
		bool mini_x_remainder = fuzzy_remainder(vert.x, grid_x * minigrid_x, dot_size / 2.0);
		bool mini_y_remainder = fuzzy_remainder(vert.y, grid_y * minigrid_y, dot_size / 2.0);
		if (mini_x_remainder && mini_y_remainder) {
			COLOR = mix(dots, background, 0.5);
		}
	}
}
