shader_type spatial;
// https://www.shadertoy.com/view/4sdfDS#
#define noiseScale1 128.0/resolution.x
#define noiseScale2 128.0/resolution.x
#define noiseScale3 128.0/resolution.x

#define pointScale1 2.5*resolution.x/512.0
#define pointScale2 2.5*resolution.x/512.0
#define pointScale3 2.5*resolution.x/512.0

#define potentialScale 1.0/resolution.x

#define fade clamp(0.0019*resolution.x, 0.9, 0.99)
#define offset 0.00001*clamp(resolution.x, 0.0, 00.0)

const vec2 epsilon = vec2(0.01, 0);

const vec4 pi = vec4(0,2,4,8)*atan(1.0);

uniform sampler2D noise;
uniform vec2 mouse_pos;
uniform vec2 resolution;

vec3 random3(vec3 c)
{
	return texture(noise, (c*0.03125).xy).rgb - 0.5;
}

const float F3 =  0.3333333333;
const float G3 =  0.1666666667;

//thanks nikat
float simplex3d(vec3 p)
{
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));

	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 vec4 w, d;
	 
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 w = max(0.75 - w, 0.0);
	 
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 return dot(d, vec4(6.0));
}

float potential(vec2 p2){
    vec3 p = vec3(p2, 0.1*TIME);
    float result = noiseScale1*simplex3d(pointScale1*p);
    result += noiseScale2*simplex3d(pointScale2*p);
    result += noiseScale3*simplex3d(pointScale3*p);
    result *= potentialScale;
    return result;
}

vec2 curl(vec2 p){
    vec2 result = vec2(potential(p + epsilon.yx), potential(p + epsilon));
    result -= potential(p);
    result /= epsilon.x;
    return vec2(-result.x, result.y);
}

void fragment () {
	ALBEDO = vec3(0.0);
    vec2 uv = UV;
    
    vec2 v = curl(uv*vec2(1, resolution.y / resolution.x)) * 5.0;
//    ALBEDO = fade * texture(iChannel0, uv - v - vec2(0, offset));
	vec3 col = ALBEDO * fade;
    
    
    vec2 p = FRAGCOORD.xy - (mouse_pos / resolution);
    float d = max(1.0 - 0.000001*resolution.x*dot(p, p / 3.0), 0.0);
    col += (vec4(d * d) * (0.5 + 0.5 * sin(4.0 * pi.y * uv.y + pi))).rgb;
    ALBEDO = vec3((col.r + col.b + col.g) / 3.0);
}