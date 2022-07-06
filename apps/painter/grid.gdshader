shader_type canvas_item;

uniform int grid_x;
uniform int grid_y;

uniform vec4 background: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 dots: source_color = vec4(0.5, 0.5, 0.5, 1.0);

varying vec2 v;

void vertex() {
	v = VERTEX;
}

void fragment() {
	bool x_remainder = (
		(int(v.x) % grid_x == 0)
		|| (int(v.x + 1.0) % grid_x == 0)
		|| (int(v.x - 1.0) % grid_x == 0)
	);
	bool y_remainder = (
		(int(v.y) % grid_y == 0)
		|| (int(v.y + 1.0) % grid_y == 0)
		|| (int(v.y - 1.0) % grid_y == 0)
	);
	
	if (x_remainder && y_remainder) {
		COLOR = dots;
	} else {
		COLOR = background;
	}
}
