shader_type spatial;
render_mode unshaded, depth_draw_never, cull_back;

uniform vec4 tint : source_color; // tint effect
uniform float wave_speed = 0.2; // wave loop speed
uniform sampler2D noise;
uniform float noise_force;


void fragment(){
	
	vec2 p = texture( noise, -UV ).xy + TIME * wave_speed;
	float line_noise = clamp( ( sin( texture( noise, p, 2.0 ).r * PI ) - 0.95 ) * 45.0, 0.0, 2.0 ) * noise_force;
	vec3 line_color = texture( SCREEN_TEXTURE, SCREEN_UV + line_noise ).rgb;
	vec3 fog_color = texture( SCREEN_TEXTURE, SCREEN_UV + texture(noise, vec2( UV.x - TIME * wave_speed, UV.y)).r).rgb;
	
	vec3 a = mix( fog_color.rgb, line_color.rgb, ( abs(line_noise) < 0.1 ) ? 1.0 : 0.0 ) + (tint.rgb * tint.a);
	vec3 b = textureLod(SCREEN_TEXTURE, SCREEN_UV, 8.0).rgb;
	ALBEDO = mix(a, b, 0.5) + 5.0 * (line_noise * tint.a);
	ALPHA = 1.0;
}