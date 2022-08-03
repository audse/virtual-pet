
group_uniforms MaterialSettings;

group_uniforms MaterialSettings.Albedo;
uniform vec3 _albedo_color: source_color = vec3(1.0);
uniform sampler2D _albedo_texture: source_color, filter_linear_mipmap, repeat_enable;

group_uniforms MaterialSettings.Light;
uniform float _metallic: hint_range(0.0, 1.0, 0.1);
uniform sampler2D _metallic_texture: hint_default_white, filter_linear_mipmap, repeat_enable;

uniform float _specular: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float _roughness: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform sampler2D _roughness_texture: hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float _ao: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float _ao_light_effect: hint_range(0.0, 1.0, 0.1) = 0.5;

group_uniforms MaterialSettings.Normal;
uniform sampler2D _normal_texture;
uniform float _normal_strength = 0.0;

group_uniforms MaterialSettings.Uv;
uniform vec3 _uv1_scale;
uniform vec3 _uv1_offset;
uniform vec3 _uv2_scale;
uniform vec3 _uv2_offset;

vec2 get_uv (vec2 uv) {
	return uv * _uv1_scale.xy + _uv1_offset.xy;
}

#ifdef INCLUDE_VERTEX
void vertex () {
	UV = get_uv(UV);
}
#endif

vec3 get_albedo (vec2 uv) {
	return _albedo_color * texture(_albedo_texture, uv).rgb;
}

vec3 get_normal_map (vec2 uv) {
	return texture(_normal_texture, uv).rgb;
}

float get_metallic (vec2 uv) {
	return _metallic * texture(_metallic_texture, uv).r;
}

float get_roughness (vec2 uv) {
	return _roughness * texture(_roughness_texture, uv).r;
}

#ifdef INCLUDE_FRAGMENT
void fragment () {
	ALBEDO = get_albedo(UV);
	NORMAL_MAP = get_normal_map(UV);
	NORMAL_MAP_DEPTH = _normal_strength;
	METALLIC = get_metallic(UV);
	ROUGHNESS = get_roughness(UV);
	SPECULAR = _specular;
	AO = _ao;
	AO_LIGHT_AFFECT = _ao_light_effect;
}
#endif