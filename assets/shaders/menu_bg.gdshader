shader_type canvas_item;

// Animated dark atmospheric background for menus
// Smooth drifting fog with subtle purple magical glow

uniform vec4 base_color : source_color = vec4(0.06, 0.05, 0.09, 1.0);
uniform vec4 fog_color : source_color = vec4(0.18, 0.12, 0.28, 1.0);
uniform vec4 magic_color : source_color = vec4(0.40, 0.15, 0.55, 1.0);
uniform float time_scale : hint_range(0.01, 0.5) = 0.04;

// Smooth value noise using quintic interpolation
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float smooth_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	// Quintic Hermite curve for smooth interpolation
	vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	for (int i = 0; i < 6; i++) {
		v += amp * smooth_noise(p);
		p = rot * p * 2.0;
		amp *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * time_scale;

	// Two layers of drifting fog at different speeds and scales
	float fog1 = fbm(uv * 3.0 + vec2(t * 0.6, t * 0.2));
	float fog2 = fbm(uv * 4.5 + vec2(-t * 0.4, t * 0.35));
	float fog = mix(fog1, fog2, 0.5);

	// Third layer for depth
	float fog3 = fbm(uv * 2.0 + vec2(t * 0.15, -t * 0.1));

	// Vignette (darker at edges)
	float vignette = 1.0 - length((uv - 0.5) * 1.5);
	vignette = clamp(vignette, 0.0, 1.0);
	vignette = smoothstep(0.0, 1.0, vignette);

	// Build color
	vec3 col = base_color.rgb;

	// Apply fog layers — stronger blend for more visible fog
	col = mix(col, fog_color.rgb, fog * 0.55);
	col = mix(col, fog_color.rgb * 1.3, fog3 * 0.25);

	// Soft magical glow spots (using high-frequency fbm)
	float glow = fbm(uv * 6.0 + vec2(t * 0.3, -t * 0.2));
	glow = smoothstep(0.5, 0.7, glow);
	float pulse = sin(TIME * 0.8 + fbm(uv * 3.0) * 6.28) * 0.3 + 0.7;
	col += magic_color.rgb * glow * pulse * 0.3;

	// Apply vignette
	col *= (0.6 + vignette * 0.4);

	COLOR = vec4(col, 1.0);
}
