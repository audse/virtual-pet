shader_type canvas_item;

uniform float grid_x = 50.0;
uniform float grid_y = 50.0;

uniform vec4 background: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 dots: source_color = vec4(0.5, 0.5, 0.5, 1.0);

varying vec2 vert;

void vertex() {
	vert = VERTEX;
}

bool fuzzy_remainder(float x, float y) {
	
	// x = 210, y = 50
	// remainder = floor (210 / 50) = 4
	// target = 4 * 50 = 200
	// is = 200 - 210 
	float remainder = round(x / y);
	float target = remainder * y;
	bool is = abs(target - x) < 2.0;
	
	return is;
}

void fragment() {
	bool x_remainder = fuzzy_remainder(vert.x, grid_x);
	bool y_remainder = fuzzy_remainder(vert.y, grid_y);
	
	if (x_remainder && y_remainder) {
		COLOR = dots;
	} else {
		COLOR = background;
	}
}
