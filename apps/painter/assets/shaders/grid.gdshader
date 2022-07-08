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
	int ix = int(x);
	int iy = int(y);
	bool is_fuzzy = (
		(ix % iy == 0)
		|| ((ix + 1) % iy == 0)
		|| ((ix - 1) % iy == 0)
	);
	return is_fuzzy;
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
