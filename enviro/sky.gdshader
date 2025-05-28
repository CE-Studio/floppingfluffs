shader_type sky;

uniform vec3 sky_color: source_color;

uniform sampler3D clouds;

float sample_density(vec3 pos) {
	return texture(clouds, pos * 0.1).r;
}

vec4 raymarch(vec3 camera_origin, vec3 camera_direction) {
	float time = 0.0;
	float total_density = 0.0;
	vec3 color = vec3(0.0);

	for (int i = 0; i < 64; i++) {
		vec3 anchored_origin = floor((POSITION + camera_direction * 100.0 + vec3(0.0, 10.0, 0.0)) / 100.0) * 100.0;
		vec3 pos = anchored_origin + camera_direction * time;
		pos += vec3(0.1, 0.0, 0.02) * TIME;

		// Sample at two different altitudes and blend
		float d1 = sample_density(pos);
		float d2 = sample_density(pos + vec3(0.0, 3.0, 0.0)); // higher altitude
		float density = mix(d1, d2, 0.5);
		density = clamp((density - 0.3) * 2.5, 0.0, 1.0);
		density = pow(density, 2.0); // cartoon-style shaping



		float alpha = density * 0.03;
		vec3 sun_dir = -LIGHT0_DIRECTION;
		float light = clamp(dot(normalize(sun_dir), normalize(camera_direction)), 0.0, 1.0);
		light = smoothstep(0.3, 0.7, light); // stylized rim lighting
		vec3 lighting = mix(vec3(0.4, 0.5, 0.6), vec3(1.0), light);

		color += lighting * density * (1.0 - total_density);
		total_density += alpha * (1.0 - total_density);
		if (total_density > 0.95) break;
		time += 0.1;
	}
	return	vec4(color, total_density);
}
void sky() {
	vec3 origin = POSITION;
	vec3 direction = EYEDIR;

	vec4 result = raymarch(origin, direction);

	COLOR = mix(sky_color, result.rgb, result.a);

	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
}