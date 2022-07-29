shader_type spatial;
// by Nikos Papadopoulos, 4rknova / 2019
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const vec3 WATER_COLOR = vec3(0.92, 0.95, 1.0);

const float STRENGTH = 1.75;
const float MODIFIER = 0.99;
const float STEP = 2.0;

uniform vec2 resolution = vec2(1000);
uniform sampler2D tex;
uniform vec2 mouse_pos;
uniform int frame = 0;

float S (vec2 p, vec2 e) {
	return texture(tex, p+e).x;
}

vec3 getPos()
{
    if (mouse_pos.y > 0.) return vec3(mouse_pos.xy, 1);
  	return vec3(0);
}

//void fragment () {
//    float d = 0.;
//    vec2  p = FRAGCOORD.xy / resolution.xy;
//    vec4  c = texture(tex, p);
//   	vec3  e = vec3(vec2(STEP)/resolution.xy,0.);
//   	float s0 = c.y, s1 = S(p, -e.zy), s2 = S(p, -e.xz), s3 = S(p, e.xz), s4 = S(p, e.zy);
//
//   	vec3 pos = getPos();
//   	if (pos.z > 0.5) d = STRENGTH * smoothstep(3.,0.5,length(pos.xy - FRAGCOORD.xy));
//
//   	// Calculate new state
//   	d += -(s0 - .5) * 2. + (s1 + s2 + s3 + s4 - 2.);
//   	d *= MODIFIER;
//    d *= smoothstep(0.,1.,float(frame >= 60)); // Clean buffer at startup
//    d = d * 0.5 + 0.5;
// 	ALBEDO = vec3(d, c.x, 0); // Save current and previous state
//	ALPHA = 0.5;
//}

void fragment () {
    vec2 uv = UV;
    
    vec4 col = vec4(0);
    
   	vec2 tc = texture(tex, uv).xy;
   	col = texture(tex, tc - (0.5 - uv));
   	col.xyz *= WATER_COLOR;
   	vec3 n = normalize(vec3(length(dFdx(tc)), length(dFdy(tc)), DEPTH/max(resolution.x, resolution.y)));
   	col.xyz += pow(dot(n,normalize(vec3(.9,.25,-.1))),2.0) * pow(textureLod(tex, n, 5.).xyz,vec3(SPECULAR));
    
    fragColor = col;
}