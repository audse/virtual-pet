shader_type spatial;
render_mode shadows_disabled, specular_toon, cull_disabled;

// distortion variables
uniform float speed = 0.1;
uniform int range_low = 2;
uniform int range_high = 25;
uniform int step_amount = 1;
uniform vec2 resolution = vec2(1024);
uniform float mouse_scale = 1.0;
uniform vec2 mouse_pos;
uniform float intensity = 0.75;

// water texture variables
uniform vec2 wave_speed = vec2( 1.0, 1.0 );
uniform float voronoi_scale = 18.0;
uniform float noise_scale = 0.21;
uniform vec4 color: source_color = vec4( 0.01, 0.5866666666666666, 1.0, 1.0 );
uniform vec4 light_color: source_color = vec4( 1.0, 1.0, 1.0, 1.0 );


vec2 get_mouse_pos() {
	return mouse_pos / resolution;
}

vec3 Effect(float speed_val, vec2 uv) {

	vec2 mouse = get_mouse_pos();
    float t = TIME * speed_val;
    float rt = (t * 0.45);
    float irt = (t * 0.005);
    mat2 m1 = mat2(vec2(sin(rt),cos(rt)), vec2(-cos(rt),sin(rt)));
    vec2 uva=m1*uv;
    mat2 m2 = mat2(vec2(sin(irt),cos(irt)), vec2(-cos(irt),sin(irt)));
	for(int i=range_low;i<range_high;i+=step_amount)
	{	
		float it = float(i);
        uva.y+=-it+(0.75/it) * cos(t + it*uva.x + 0.5*it)
           *float(mod(it,2.0)==0.0);
		uva.x+=it+(0.5/it) * cos(t + it*uva.y + 0.5*(it+25.0));
	}
    //Intensity range from 0 to n;
    float n = intensity;
    float rgb = clamp(n + n * sin(4.0*uva.x+t), 0.15, 0.85);
    vec3 fc = vec3(rgb);
    vec3 gs = vec3(fc.x*0.33 *fc.y*0.33 + fc.z*0.33)*0.56;
	return mix(fc,gs,pow(min(length(uv)*0.65,1.0),0.75));
}
vec2 random( vec2 pos )
{ 
	return fract(
		sin(
			vec2(
				dot(pos, vec2(12.9898,78.233))
			,	dot(pos, vec2(-148.998,-65.233))
			)
		) * 43758.5453
	);
}

float value_noise( vec2 pos )
{
	vec2 p = floor( pos );
	vec2 f = fract( pos );

	float v00 = random( p + vec2( 0.0, 0.0 ) ).x;
	float v10 = random( p + vec2( 1.0, 0.0 ) ).x;
	float v01 = random( p + vec2( 0.0, 1.0 ) ).x;
	float v11 = random( p + vec2( 1.0, 1.0 ) ).x;

	vec2 u = f * f * ( 3.0 - 2.0 * f );

	return mix( mix( v00, v10, u.x ), mix( v01, v11, u.x ), u.y );
}

float voronoi( vec2 v )
{
	vec2 v_floor = floor( v );
	vec2 v_fract = fract( v );

	float min_dist = 2.0;

	for( int y = -1; y <= 1; y ++ ) {
		for( int x = -1; x <= 1; x ++ ) {
			vec2 n = vec2( float( x ), float( y ) );
			vec2 p = random( v_floor + n );
			vec2 diff = p + n;
			float d = distance( v_fract, diff );

			min_dist = min( min_dist, d );
		}
	}

	return min_dist;
}

varying vec3 col;
varying float f;

void vertex () {
	// distortion shader
    vec2 mouse = mouse_pos.xy / resolution.xy;
    mouse = 2.0 * mouse - 1.0;
    mouse.x *= resolution.x / resolution.y;
	
	vec2 uv = UV;
   	uv = 2.0 * uv - 1.0;
    uv.x *= resolution.x / resolution.y;
	
    float l = length(uv - mouse) / mouse_scale;
    uv *= abs(uv)/(abs(uv)+exp(-l*8.0));
	col = Effect(speed, uv) * 0.75;
	VERTEX.y += col.r;
	
	vec2 water_uv = UV;
	vec2 noise_uv = UV + wave_speed * TIME * 0.1;

	water_uv.x += (
		value_noise( noise_uv * 5.45432 ) * 0.5
	+	value_noise( noise_uv * 15.754824 ) * 0.25
	+	value_noise( noise_uv * 35.4274729 ) * 0.125
	+	value_noise( noise_uv * 95.65347829 ) * 0.0625
	+	value_noise( noise_uv * 285.528934 ) * 0.03125
	+	value_noise( noise_uv * 585.495328 ) * 0.015625
	+	value_noise( noise_uv * 880.553426553 ) * 0.0078125
	+	value_noise( noise_uv * 2080.5483905843 ) * 0.00390625
	) * noise_scale;

	vec2 v1 = water_uv * voronoi_scale + vec2( 100.0 + TIME ) * wave_speed;
	vec2 v2 = water_uv * voronoi_scale + vec2( -100.0 + TIME * 0.83 ) * wave_speed;

	f = mix(
		voronoi( v1 ) * 1.1
	,	voronoi( v2 ) * 1.1
	,	sin( TIME * 0.758 ) * 0.5 + 0.5
	);
	VERTEX.y += f * intensity / 5.0;
}

void fragment () {
	// distortion
	ALBEDO = col - vec3(0.25);
	ROUGHNESS = 1.0;
	METALLIC = 0.1;
	ALPHA = 0.4 + ALBEDO.r / 2.0;
	
	// water
	ALBEDO = mix(ALBEDO, mix(light_color, color, clamp(1.0 - f * f * f, 0.0, 1.0 )).rgb, 0.25);
}
