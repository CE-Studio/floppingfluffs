shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_toon, specular_toon;

uniform sampler2D color_gradient;
uniform sampler2D fresnel_gradient;
uniform sampler2D alpha_texture;
uniform float alpha_threshold;
uniform vec4 color:source_color;
uniform float offsetScale : hint_range(0.0001, 10.0, 0.1);
varying float transparency;



float fresnel (float amount, vec3 normal, vec3 view) {
	return pow(1.0 - clamp(dot(normalize(normal),normalize(view)),0.0,1.0), amount);
}

void vertex() {
	vec2 uvOffset = vec2((UV.x * 2.0 - 1.0), -(UV.y * 2.0 - 1.0));
	uvOffset /= 2.0;
	vec4 off = inverse(MODELVIEW_MATRIX) * vec4(uvOffset, 1.0, 0.0);
	off = vec4(normalize(off.xyz), 0.0) * offsetScale;
	transparency = COLOR.r;
	VERTEX += off.xyz;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float basic_fresnel = fresnel(4.0, NORMAL, VIEW);
	ALPHA = texture(alpha_texture, UV).x;
	ALBEDO = color.xyz + (basic_fresnel * texture(fresnel_gradient, vec2(basic_fresnel,0.0)).rgb);

	ALPHA_SCISSOR_THRESHOLD = alpha_threshold ;

	// Called for every pixel the material is visible on.
}

void light() {
	float dotproduct = clamp(dot(NORMAL, LIGHT), -0.9, 0.9);
	float sample = clamp((dotproduct + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 shaded = texture(color_gradient, vec2(sample, 0.0));
	DIFFUSE_LIGHT += clamp((shaded.rgb * LIGHT_COLOR), 0.0, 1.0);
}
