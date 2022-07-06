shader_type spatial;

varying vec3 pos;

void vertex() {
    pos = VERTEX;
}

void fragment() { 
	if (pos.x > -0.25 && pos.z > -0.25 && pos.y > -0.25) {
        discard;
    }
}
