shader_type spatial;
render_mode world_vertex_coords;

uniform vec3 size = vec3(1.0);
uniform vec4 color: source_color;

uniform bool show_grid = false;
uniform float grid_size = 0.25;
uniform bool show_dots = false;
uniform float dot_size = 0.25;

varying vec3 vert;

void vertex () {
	vert = VERTEX; 
}

void fragment () {
	ALPHA = 0.0;
	ALBEDO = vec3(0.0);
	
	vec3 v = vert / size;
	vec3 rem = abs(v - floor(v)) * vec3(1.0, 0.0, 1.0);
	
	if (show_grid) {
		vec3 dist = vec3(1.0) - rem;
		float distf = min(min(dist.x, dist.y), dist.z);
		bool is_grid = distf < (grid_size * 0.1);
		ALBEDO = is_grid ? color.rgb : ALBEDO;
		ALPHA = is_grid ? color.a : ALPHA;
	}
	if (show_dots) {
//		float next_dot_size = clamp(abs(cos(TIME * 2.0)) * dot_size, 0.2, 1.0);
		vec3 tl_dist = vec3(0.0, 0.0, 0.0) - rem;
		vec3 tr_dist = vec3(1.0, 0.0, 0.0) - rem;
		vec3 bl_dist = vec3(0.0, 0.0, 1.0) - rem;
		vec3 br_dist = vec3(1.0, 0.0, 1.0) - rem;
		
		float distf = min(min(length(tl_dist), length(tr_dist)), min(length(bl_dist), length(br_dist)));
		bool is_dot = distf < (dot_size * 0.1);
		ALBEDO = is_dot ? color.rgb : ALBEDO;
		ALPHA = is_dot ? color.a : ALPHA;
	}
}
