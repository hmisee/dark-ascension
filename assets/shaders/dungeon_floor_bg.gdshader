shader_type canvas_item;

// Infinite tiling dungeon stone floor for gameplay.
// camera_offset is set each frame by ScrollingBackground.gd

uniform vec2 camera_offset = vec2(0.0, 0.0);
uniform vec4 base_color : source_color = vec4(0.10, 0.08, 0.14, 1.0);
uniform vec4 grout_color : source_color = vec4(0.05, 0.04, 0.07, 1.0);
uniform vec4 accent_color : source_color = vec4(0.22, 0.12, 0.32, 1.0);

// Pixels per stone tile — controls how big each tile looks on screen
uniform float tile_pixel_size : hint_range(32.0, 256.0) = 96.0;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float smooth_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
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
	for (int i = 0; i < 4; i++) {
		v += amp * smooth_noise(p);
		p = rot * p * 2.0;
		amp *= 0.5;
	}
	return v;
}

void fragment() {
	// World position in pixels, then convert to tile coordinates
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 screen_pixel = UV * viewport_size;
	vec2 world_pixel = camera_offset + screen_pixel - viewport_size * 0.5;

	// Tile coordinates: each tile is tile_pixel_size x tile_pixel_size pixels
	// Use 2:1 aspect ratio for rectangular stone slabs
	vec2 tile_coord = world_pixel / vec2(tile_pixel_size * 2.0, tile_pixel_size);

	// Brick offset: shift every other row by half
	float row = floor(tile_coord.y);
	tile_coord.x += step(1.0, mod(row, 2.0)) * 0.5;

	vec2 tile_id = floor(tile_coord);
	vec2 tile_f = fract(tile_coord);

	// Grout lines (mortar between stones)
	float grout_w = 0.05;
	float mx = smoothstep(0.0, grout_w, tile_f.x) * smoothstep(0.0, grout_w, 1.0 - tile_f.x);
	float my = smoothstep(0.0, grout_w, tile_f.y) * smoothstep(0.0, grout_w, 1.0 - tile_f.y);
	float grout = mx * my;

	// Per-tile random values
	float tile_rand = hash(tile_id);
	float brightness_var = tile_rand * 0.07 - 0.035;

	// Stone surface texture (use world_pixel for detail independent of tile grid)
	float surface = fbm(world_pixel * 0.02) * 0.04;
	float detail = smooth_noise(world_pixel * 0.05) * 0.02;

	// Compose base stone color
	vec3 col = base_color.rgb + brightness_var + surface + detail;

	// Grout is darker
	col = mix(grout_color.rgb, col, grout);

	// Some tiles are darker (cracked / worn)
	float worn = step(0.85, tile_rand) * 0.05;
	col -= worn;

	// Subtle purple glow patches across the floor
	float glow = fbm(world_pixel * 0.004);
	glow = smoothstep(0.5, 0.75, glow) * 0.12;
	col += accent_color.rgb * glow;

	COLOR = vec4(col, 1.0);
}
