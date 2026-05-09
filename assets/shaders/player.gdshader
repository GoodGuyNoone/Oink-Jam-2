shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color;

uniform float fade_start = 0.10;
uniform float fade_end = 0.55;
uniform float dither_scale = 1.0;

varying vec3 world_pos;

float dither4x4(vec2 position) {
	int x = int(mod(position.x, 4.0));
	int y = int(mod(position.y, 4.0));
	int index = x + y * 4;

	float matrix[16] = float[](
		0.0,  8.0,  2.0, 10.0,
		12.0, 4.0, 14.0, 6.0,
		3.0, 11.0, 1.0, 9.0,
		15.0, 7.0, 13.0, 5.0
	);

	return matrix[index] / 16.0;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float dist = distance(CAMERA_POSITION_WORLD, world_pos);
	float fade = smoothstep(fade_start, fade_end, dist);

	float dither = dither4x4(FRAGCOORD.xy * dither_scale);

	if (dither > fade) {
		discard;
	}

	vec4 tex = texture(albedo_texture, UV);

	ALBEDO = tex.rgb;
	ROUGHNESS = 0.65;
}