shader_type spatial;

varying vec3 position;
varying float direction;
varying vec3 next;
varying vec3 previous;

uniform float aspect;
uniform float thickness;
uniform int miter;

void vertex () {
	vec2 aspectVec = vec2(aspect, 1.0);
	vec4 previousProjected = MODELVIEW_MATRIX * vec4(previous, 1.0);
	vec4 currentProjected = MODELVIEW_MATRIX * vec4(position, 1.0);
	vec4 nextProjected = MODELVIEW_MATRIX * vec4(next, 1.0);

	//get 2D screen space with W divide and aspect correction
	vec2 currentScreen = currentProjected.xy / currentProjected.w * aspectVec;
	vec2 previousScreen = previousProjected.xy / previousProjected.w * aspectVec;
	vec2 nextScreen = nextProjected.xy / nextProjected.w * aspectVec;

	float len = thickness;
	float orientation = direction;

	//starting point uses (next - current)
	vec2 dir = vec2(0.0);
	if (currentScreen == previousScreen) {
		dir = normalize(nextScreen - currentScreen);
	} 
	//ending point uses (current - previous)
	else if (currentScreen == nextScreen) {
		dir = normalize(currentScreen - previousScreen);
	}
	//somewhere in middle, needs a join
	else {
		//get directions from (C - B) and (B - A)
  		vec2 dirA = normalize((currentScreen - previousScreen));
		if (miter == 1) {
			vec2 dirB = normalize((nextScreen - currentScreen));
			//now compute the miter join normal and length
			vec2 tangent = normalize(dirA + dirB);
			vec2 perp = vec2(-dirA.y, dirA.x);
			vec2 miter_len = vec2(-tangent.y, tangent.x);
			dir = tangent;
			len = thickness / dot(miter_len, perp);
	  	} else {
			dir = dirA;
		}
	}
	vec2 normal = vec2(-dir.y, dir.x);
	normal *= len/2.0;
	normal.x /= aspect;
	
	vec4 offset = vec4(normal * orientation, 0.0, 1.0);
	VERTEX = (currentProjected + offset).xyz;
	POINT_SIZE = 1.0;
}

void fragment () {
	ALBEDO = vec3(1.0, 0.0, 0.0);
}