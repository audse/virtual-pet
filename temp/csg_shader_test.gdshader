shader_type spatial;

uniform sampler2D normal_map;
uniform int slices = 5;

// this is all bad

void vertex () {
	vec3 rounded = round(VERTEX * 50.0) / 50.0;
	float width = 1.0 / float(slices);
	int index = int(VERTEX.z / width);
	float offset = (width * float(index)) - VERTEX.z;
	
	rounded.z += offset > 0.1 ? 0.1 : 0.0;
	VERTEX = rounded;
}

void fragment () {
	NORMAL_MAP = texture(normal_map, UV).rgb;
}