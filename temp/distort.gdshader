shader_type spatial;

uniform sampler2D albedo_texture: source_color;
uniform vec4 albedo_color: source_color = vec4(1.0);
uniform sampler2D normal_texture: hint_normal;
uniform float normal_depth = 1.0;
uniform vec2 normal_scale = vec2(1.0);
uniform bool is_corner = false;
uniform vec3 distort_amount = vec3(0.0);
uniform float uv_rotation = 0.0;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}

void vertex() {
	
	vec3 world_vertex = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 distortion = vec3(0.0);
	
	bool is_left = VERTEX.x <= -0.5;
	bool is_right = VERTEX.x >= 0.5;
	bool is_top = VERTEX.z <= -0.5;
	bool is_bottom = VERTEX.z >= 0.5;

	if (is_left && is_bottom && is_corner) {
		distortion = distort_amount;
		
	} else if (!is_corner) {
		bool is_x_center = VERTEX.x >= -0.5 && VERTEX.x <= 0.5;
		
		if (is_x_center && VERTEX.y >= 1.0) {
			distortion = distort_amount / 3.0;
		}
	}
	float y_offset = world_vertex.y / 4.0;
	
	VERTEX += distortion * 1.5 * y_offset;
}

void fragment() {
	vec2 uv = rotateUV(UV, vec2(0.0), uv_rotation);	
	
	NORMAL_MAP = texture(normal_texture, uv * normal_scale).rgb;
	NORMAL_MAP_DEPTH = normal_depth;
	ALBEDO = texture(albedo_texture, uv).rgb * albedo_color.rgb;
	AO = 1.0;
	AO_LIGHT_AFFECT = 0.25;
}