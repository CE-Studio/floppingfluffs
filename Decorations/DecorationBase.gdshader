shader_type spatial;


void fragment() {
	float hue = mod(TIME * 0.02, 1.0); // 0.2 controls speed

	// HSV to RGB conversion
	float s = 1.0;
	float v = 1.0;
	float c = v * s;
	float h = hue * 6.0;
	float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));

	vec3 rgb;

	if (0.0 <= h && h < 1.0)      rgb = vec3(c, x, 0.0);
	else if (1.0 <= h && h < 2.0) rgb = vec3(x, c, 0.0);
	else if (2.0 <= h && h < 3.0) rgb = vec3(0.0, c, x);
	else if (3.0 <= h && h < 4.0) rgb = vec3(0.0, x, c);
	else if (4.0 <= h && h < 5.0) rgb = vec3(x, 0.0, c);
	else                          rgb = vec3(c, 0.0, x);

	vec3 m = vec3(v - c);
	ALBEDO = rgb + m;
}
	// Called for every pixel the material is visible on.


//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
