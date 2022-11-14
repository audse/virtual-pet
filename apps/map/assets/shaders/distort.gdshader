shader_type spatial;
render_mode depth_draw_always;

group_uniforms CutoutRect;
uniform vec3 cut_pos = vec3(-1.0);
uniform vec3 cut_size = vec3(-1.0);

group_uniforms MaterialSettings;
uniform sampler2D albedo_texture;
uniform vec4 albedo_color: source_color = vec4(1.0);
uniform sampler2D normal_texture;
uniform float normal_depth = 1.0;
uniform vec2 normal_scale = vec2(1.0);
uniform float uv_rotation = 0.0;

group_uniforms DistortionSettings;
uniform bool is_corner = false;
uniform vec3 distort_amount = vec3(0.0);

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}

varying vec3 world_vertex;

void vertex () {
	
	vec3 distortion = vec3(0.0);
	
	bool is_left = VERTEX.x <= -0.5;
//	bool is_right = VERTEX.x >= 0.5;
//	bool is_top = VERTEX.z <= -0.5;
	bool is_bottom = VERTEX.z >= 0.5;

	if (is_left && is_bottom && is_corner) {
		distortion = distort_amount;
		
	} else if (!is_corner) {
		bool is_x_center = VERTEX.x >= -0.5 && VERTEX.x <= 0.5;
		
		if (is_x_center && VERTEX.y >= 0.5) {
			distortion = distort_amount / 3.0;
		}
	}
//	float y_offset = world_vertex.y / 4.0;
	
	VERTEX += distortion * 1.5;
	
	world_vertex = VERTEX;
}

void fragment () {
	vec2 uv = rotateUV(UV, vec2(0.0), uv_rotation);	
	NORMAL_MAP_DEPTH = normal_depth;
	
	NORMAL_MAP = texture(normal_texture, uv * normal_scale).rgb;
	ALBEDO = texture(albedo_texture, uv).rgb * albedo_color.rgb;
	AO = 1.0;
	AO_LIGHT_AFFECT = 0.25;
//	EMISSION = vec3(0);

	if (distance(cut_pos, cut_pos + cut_size) > 0.05) {
		bool is_within_x = world_vertex.x >= cut_pos.x && world_vertex.x <= (cut_pos.x + cut_size.x);
		bool is_within_y = world_vertex.y >= cut_pos.y && world_vertex.y <= (cut_pos.y + cut_size.y);
		bool is_within_z = world_vertex.z >= cut_pos.z && world_vertex.z <= (cut_pos.z + cut_size.z);
		
		if (is_within_x && is_within_y && is_within_z) {
			ALPHA = 0.0;
		}
	}
}