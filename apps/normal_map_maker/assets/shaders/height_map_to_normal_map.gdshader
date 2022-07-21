shader_type canvas_item;

uniform sampler2D image;
uniform vec2 resolution;
uniform float power: hint_range(-64.0, 64.0, 1.0);

float gray (vec3 rgb) {
	return rgb.r * 0.299 + rgb.g * 0.587 + rgb.b * 0.114;
}

vec2 calcAspect (vec2 iRes) {
    vec2 aspect = vec2(float(iRes.x < iRes.y) * iRes.x / iRes.y,
					   float(iRes.y < iRes.x) * iRes.y / iRes.x);
    aspect.x += float(aspect.x == 0.0);
    aspect.y += float(aspect.y == 0.0);
    return aspect;
}

void fragment () {
    // Normalized pixel coordinates (from 0 to 1)
    float s = 1.5;
    vec2 a = calcAspect(resolution.xy);
	
	vec2 uv = UV;
    
    // It is more correct to take the resolution of the original texture
    vec2 ts = (1.0 / resolution.xy); // texel step
    
    vec3 t1 = texture(image, uv + vec2( 1.0,  0.0) * ts).xyz;
    vec3 t2 = texture(image, uv + vec2(-1.0,  0.0) * ts).xyz;
    vec3 t3 = texture(image, uv + vec2( 0.0,  1.0) * ts).xyz;
    vec3 t4 = texture(image, uv + vec2( 0.0, -1.0) * ts).xyz;
    
    float b1 = 0.5 + gray(vec3(t1 * power - t2 * power)); // left bevel
    float b2 = 0.5 + gray(vec3(t3 * power - t4 * power)); // top  bevel
    
    vec3 r = (1.0 - b1) * vec3( 1.0,  0.0, 1.0); // triplanar multiply
    vec3 l =        b1  * vec3(-1.0,  0.0, 1.0);
    vec3 t = (1.0 - b2) * vec3( 0.0,  1.0, 1.0);
    vec3 d =        b2  * vec3( 0.0, -1.0, 1.0);
    
    vec3 n = normalize(r + l + t + d); // result normal
    
    vec3 color = n * 0.5 + 0.5;
    
	// this section makes it grey !
    if (uv.x > s * 0.5) {
//        float t = 1.0 * 0.6;
//        vec2 rot = vec2(sin(t), cos(t));
//        vec3 ld = vec3(rot, 0.2); // light direction
//        float ad = 0.1 + dot(ld, n); // ambient + diffuse
//        color = vec3(ad);
    }
    
    COLOR = vec4(color, 1.0);
}