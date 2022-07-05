shader_type spatial;

uniform vec4 albedo_color: source_color;
uniform vec3 top_left_distort = vec3(0.0);
uniform vec3 top_right_distort = vec3(0.0);
uniform vec3 bottom_left_distort = vec3(0.0);
uniform vec3 bottom_right_distort = vec3(0.0);

void vertex () {
    vec3 distortion = vec3(0.0);

	bool is_left = VERTEX.x <= -0.5;
	bool is_right = VERTEX.x >= 0.5;
	bool is_top = VERTEX.z <= -0.5;
	bool is_bottom = VERTEX.z >= 0.5;

    if (is_top && is_left) {
        distortion += top_left_distort;
    } else if (is_top && is_right) {
        distortion += top_right_distort;
    } else if (is_bottom && is_left) {
        distortion += bottom_left_distort;
    } else if (is_bottom && is_right) {
        distortion += bottom_right_distort;
    }

    VERTEX += distortion;
}

void fragment () {
    ALBEDO = albedo_color.rgb;
}