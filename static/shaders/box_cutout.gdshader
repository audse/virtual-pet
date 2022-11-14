shader_type spatial;
render_mode world_vertex_coords;

group_uniforms CutoutRect;
uniform vec3 cut_pos;
uniform vec3 cut_size;

#include "res://static/shaders/material_settings.gdshaderinc"

varying vec3 vert;

void vertex () {
	vert = VERTEX;
}

void fragment () {
	
	bool is_within_x = vert.x >= cut_pos.x && vert.x <= (cut_pos.x + cut_size.x);
	bool is_within_y = vert.y >= cut_pos.y && vert.y <= (cut_pos.y + cut_size.y);
	bool is_within_z = vert.z >= cut_pos.z && vert.z <= (cut_pos.z + cut_size.z);
	
	if (is_within_x && is_within_y && is_within_z) {
		ALPHA = 0.0;
	}
	
	ALBEDO = get_albedo(UV);
	NORMAL_MAP = get_normal_map(UV);
	NORMAL_MAP_DEPTH = _normal_strength;
	METALLIC = get_metallic(UV);
	ROUGHNESS = get_roughness(UV);
	SPECULAR = _specular;
	AO = _ao;
	AO_LIGHT_AFFECT = _ao_light_effect;
}
