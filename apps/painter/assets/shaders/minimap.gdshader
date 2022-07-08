shader_type canvas_item;

varying vec2 vert;

void vertex() {
	vert = VERTEX;
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV, 0.0);
}