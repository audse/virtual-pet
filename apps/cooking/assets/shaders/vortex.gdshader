shader_type spatial;
render_mode shadows_disabled, unshaded, blend_add;

const vec3 lightDir = normalize(vec3(10.0,15.0,5.0));
uniform sampler2D noise_tex;
uniform float vortex_strength = 0.5;

/// 0.0 for no swirl, positive for clockwise, negative for counter clockwise
uniform float vortex_direction: hint_range(-30.0, 30.0) = 10.0;

uniform vec2 resolution = vec2(1024);
uniform vec4 color: source_color = vec4( 0.01, 0.5866666666666666, 1.0, 1.0 );

float height(in vec2 uv) {
    return step(
		texture(noise_tex,uv).b * texture(noise_tex, uv + vec2(0.0, TIME * 0.1)).b, 
		0.1
	);
}

const vec2 NE = vec2(0.05,0.0);
vec3 normal(in vec2 uv) {
    return normalize(
		vec3(
			height(uv+NE.xy) - height(uv-NE.xy),
			0.0,
			height(uv+NE.yx) - height(uv-NE.yx)
		)
	);
}

varying vec2 ruv;
varying vec2 vortex_uv;
varying float dist;
varying float angle;
varying float h;

void vertex () {
	vortex_uv = UV - vec2(0.75);
	dist = length(vortex_uv);
	angle = atan(vortex_uv.y, vortex_uv.x);
	ruv = vortex_uv;
	vortex_uv = vec2(
		cos(angle + dist * vortex_direction), 
		dist + (TIME * vortex_strength / 5.0)
	);
	h = height(vortex_uv);
}

void fragment() {
	vec3 norm = normal(vortex_uv);
	vec4 vortex_albedo = mix(
        vec4(0.0), 
        mix(
            mix(
                color + color * max(0.0, dot(lightDir, norm)) * 0.2,
                vec4(ALBEDO, 0.25),
                0.2
            ),
            texture(noise_tex, norm.xz * 0.5 + 0.5),
            0.2
        ),
        min(1.0, length(ruv) * 10.0)
    ) * abs(vortex_direction / 30.0);
	
	ALBEDO = vec3(1.0) - vortex_albedo.rgb * vortex_strength;
	ALPHA = vortex_albedo.a * ALBEDO.r;
}
