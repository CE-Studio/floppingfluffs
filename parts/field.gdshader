

shader_type spatial;
render_mode cull_disabled, diffuse_toon;

uniform float wind_strength = 0.4;
uniform float wind_speed = 1.5;
uniform vec3 wind_direction = vec3(0.0, 0.0, 1.0);
uniform vec4 grass_bottom: source_color = vec4(0.4, 0.8, 0.3, 1.0);
uniform vec4 grass_top: source_color = vec4(0.4, 0.8, 0.3, 1.0);



void vertex() {
	
	float height_factor = VERTEX.y;
	
	float wave_offset = VERTEX.x * 0.3 + VERTEX.z * 0.3;
	float bend = pow(height_factor, 2.0);
	float sway = sin(TIME * wind_speed + wave_offset);
	

	vec3 offset = wind_direction * wind_strength * sway * bend;
	VERTEX += offset;
}


void fragment() {
	vec3 n = vec3(0.0,1.0,0.0);
	NORMAL = n;
	NORMAL_MAP = n ;
	ALBEDO = mix(grass_top.rgb, grass_bottom.rgb, UV.y);
}

void light() {
	// Flip the normal for backfaces
	float NdotL = max(dot(NORMAL, LIGHT),0.0);
	DIFFUSE_LIGHT = ALBEDO * LIGHT_COLOR * NdotL;
	
	
}
