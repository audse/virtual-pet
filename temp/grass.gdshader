/** A grass shader by Toadile for Godot 3.x
 * Copies, modififications, and redistrubitions are allowed and encouranged.
 * For best effect, make sure that the quad/geometry is twice the width that is 
 * normal. In most cases, a quad that is 2 by 1 will be sufficient for the grass
 * -object interaction effect to be convincing. 
 *
 * Since the grass bending uses screen space, to use SSAO and other post 
 * processing on it, the displacement portion would have to be commented out in 
 * the fragment function to enable SSAO
 */

shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque, world_vertex_coords;

// general parameters
uniform float y_offset = 0.5;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 end_color : source_color = vec4(1.0);
uniform float specular: hint_range(0,1) = 0.1;
uniform float metallic: hint_range(0,1) = 0.0;
uniform float roughness : hint_range(0,1) = 1.0;
uniform float rim: hint_range(0,1) = 0.01;
uniform float transmission: hint_range(0,1) = 0.5;
uniform sampler2D texture_albedo;
uniform sampler2D texture_normal : hint_normal;
uniform sampler2D texture_wind_noise;
uniform vec2 uv_scale = vec2(1.0,1.0);
uniform vec2 uv_offset = vec2(0.0,0.0);

// wind parameters
uniform float wind_noise_scale = 2.0;
uniform vec2 wind_direction = vec2(0.0, 1.0);
uniform float wind_speed : hint_range(0,10) = 1.0;
uniform float wind_strength : hint_range(0,10) = 1.0;

// grass properties
uniform float color_variatiion : hint_range(0, 2) = 0.5;
uniform float height : hint_range(0, 10) = 1.0;
uniform float height_variation : hint_range(0, 2) = 0.3;
uniform float flatness : hint_range(0,2) = 0.2;

// rendering settings
uniform float fade_out_distance = 30.0;
uniform float fade_out_transition = 20.0;
uniform bool y_billboard = false;
uniform float displace_intensity : hint_range(0, 2) = 1.0;
uniform float proximity_distance : hint_range(0, 2) = 1.0;
uniform bool displace = true;
uniform float alpha_scissors : hint_range(0, 1) = 0.9;
uniform bool use_normal_map_alpha = false;

// variables
varying float bend_uv_direction;
varying vec3 instance_offset;
varying float fade;

void vertex() {
	// set up grass
	VERTEX.y *= height;
	VERTEX.y += y_offset*height;
	float inverse_uv_y = 1.0-UV.y;
	COLOR = base_color*vec4(UV.y) + end_color*vec4(inverse_uv_y);

	// "h" means height
	float h_variation = float(INSTANCE_ID % 3)*height_variation*0.5;
	float inv_h_stiff = (h_variation + height+1.0) * 2.0;
	float h_stiff = 1.0/inv_h_stiff;

	// wind noise animation

	vec2 world_xy = (VIEW_MATRIX * vec4(VERTEX, 1.0)).xz*0.2*wind_noise_scale + wind_direction*TIME*wind_speed*0.51*h_stiff;
	vec4 noise_tex = texture(texture_wind_noise, world_xy);

	// animate the grass
	vec4 local_wind_direction;
	if (y_billboard)
	{
		local_wind_direction = vec4(wind_direction.x, 1.0, wind_direction.y, 0.0)*PROJECTION_MATRIX;
	} else
	{
		local_wind_direction = vec4(wind_direction.x, 1.0, wind_direction.y, 0.0)*VIEW_MATRIX;
	}
	float flat_x = sin(MODELVIEW_MATRIX[2].x)*flatness*h_stiff;
	float flat_y = cos(MODELVIEW_MATRIX[2].z)*flatness*h_stiff;
	float bend = pow(inverse_uv_y, 2);
	float n = (noise_tex.r-0.5*2.0)*bend*wind_strength;
	VERTEX.x += n*flat_x + sin(TIME*0.01*h_stiff+float(INSTANCE_ID))*n*0.1*inv_h_stiff + local_wind_direction.x*wind_strength*bend*height;
	VERTEX.z += n*flat_y + cos(TIME*0.01*h_stiff+float(INSTANCE_ID))*n*0.1*inv_h_stiff + local_wind_direction.z*wind_strength*bend*height;
	VERTEX.y += h_variation*inverse_uv_y;
	VERTEX.y -= inverse_uv_y * flatness * 0.15;

	// introduce variation per grass instance
	if (INSTANCE_ID % 2 == 0) bend_uv_direction = 1.0; else bend_uv_direction = -1.0;

	if (INSTANCE_ID % 2 == 0) instance_offset = vec3(color_variatiion*0.1); 
	else instance_offset = vec3(-color_variatiion*0.1);

	// fade out grass by shrinking it
	float view_distance = length(VERTEX - vec3(MODELVIEW_MATRIX[3].x, MODELVIEW_MATRIX[3].y, MODELVIEW_MATRIX[3].z));
	if (view_distance > fade_out_distance + fade_out_transition) fade = 1.0f; else fade = 0.0f;
	if (view_distance > fade_out_distance)
	{
		float offset = (fade_out_distance + fade_out_transition - view_distance) / fade_out_transition;
		VERTEX.y *= offset;
	}
}

//render_mode depth_draw_always; // comment out this if not wanting to use displacement and wanting SSAO

void fragment() {
	if (fade >= 0.5f) discard;
	vec2 base_uv = UV;
	base_uv.x *= 2.0;
	base_uv.x -= 0.5;
	base_uv *= uv_scale;
	base_uv += uv_offset;
	float prox = 1.0;

	vec4 albedo_tex = texture(texture_albedo,vec2(base_uv.x, base_uv.y));
	vec4 normal_tex = texture(texture_normal,vec2(base_uv.x, base_uv.y));

	// discard distant grass
	if (!use_normal_map_alpha && albedo_tex.a < alpha_scissors)
	{
		discard;
	} else if (use_normal_map_alpha && normal_tex.a < alpha_scissors)
	{
		discard;
	}

	ALBEDO = COLOR.rgb * albedo_tex.rgb * (1.0 + instance_offset) * prox;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	RIM = rim;
//	TRANSMISSION = vec3(transmission);
	NORMAL_MAP = normal_tex.rgb;

}

//shader_type spatial;
//render_mode cull_disabled, unshaded, world_vertex_coords;
//
//uniform float wind_speed = 0.2;
//uniform float wind_strength = 2.0;
//// How big, in world space, is the noise texture
//// wind will tile every wind_texture_tile_size
//uniform float wind_texture_tile_size = 20.0;
//uniform float wind_vertical_strength = 0.3;
//uniform vec2 wind_horizontal_direction = vec2(1.0,0.5);
//
//uniform sampler2D color_ramp;
//// we need a tiling noise here!
//uniform sampler2D wind_noise;
//
//uniform vec3 character_position;
//uniform float character_radius = 3.0;
//uniform sampler2D character_distance_falloff_curve;
//uniform float character_push_strength = 1.0;
//
//varying float debug_wind;
//
//void vertex() {
//
////	vec3 world_vert = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
//
//	vec2 normalized_wind_direction = normalize(wind_horizontal_direction);
//	vec2 world_uv = VERTEX.xz / wind_texture_tile_size + normalized_wind_direction * TIME * wind_speed;
//	// we displace only the top part of the mesh
//	// note that this means that the mesh needs to have UV in a way that the bottom of UV space
//	// is at the top of the mesh
//	float displacement_affect = (1.0 - UV.y);
//	float wind_noise_intensity = (textureLod(wind_noise, world_uv , 0.0).r - 0.5);
//
//	// We convert the direction of the wind into vertex space from world space
//	// if we used it directly in vertex space, rotated blades of grass wouldn't behave properly
//	vec2 vert_space_horizontal_dir = (inverse(MODEL_MATRIX) * vec4(wind_horizontal_direction, 0.0,0.0)).xy;
//	vert_space_horizontal_dir = normalize(vert_space_horizontal_dir);
//
//	vec3 bump_wind = vec3(
//		wind_noise_intensity * vert_space_horizontal_dir.x,
//		1.0 - wind_noise_intensity,
//		wind_noise_intensity * vert_space_horizontal_dir.y 
//	);
//	normalize(bump_wind);
//	bump_wind *= vec3(
//		wind_strength,
//		wind_vertical_strength,
//		wind_strength
//	);
//	VERTEX += bump_wind * displacement_affect;
//
//	// At the moment the blades are pushed away in a perfectly circular manner.
//	// We could distort the distance to the character based on a noise, to break a bit the
//	// circular shape. We could distort the falloff by sampling in a noise based on the xz coordinates.
//	// The task is left to the reader
//
//	vec3 dir_to_character = character_position - MODEL_MATRIX[3].xyz;
//	// uncomment the following line to have a horizontal only character push
////	dir_to_character.y = 0.0;
//	float distance_to_character = length(dir_to_character);
//	float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_character/character_radius);
//	// Because we operate in vertex space, we need to convert the direction to the character
//	// in vertex space. Otherwise, it wouldn't work for rotated blades of grass.
//	// comment the next line to observe how the blades are not all facing away from the character.
//	dir_to_character = (inverse(MODEL_MATRIX) * vec4(dir_to_character, 0.0)).xyz;
//	dir_to_character = normalize(dir_to_character);
//
//	// sample the curve based on how far we are from the character, in normalized coordinates
//	float falloff_curve = texture(character_distance_falloff_curve, vec2(falloff)).x;
//	// direction to character is inverted because we want to point away from it
//	VERTEX += normalize(-dir_to_character) * falloff_curve * character_push_strength * displacement_affect;
//
//}
//
//void fragment() {
//	ALBEDO = texture(color_ramp, vec2(1.0 - UV.y, 0)).rgb ;
//}