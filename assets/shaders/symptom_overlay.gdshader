shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float dizziness_intensity = 0.0;
uniform float tremor_intensity = 0.0;
uniform float heartbeat_intensity = 0.0;
uniform float time = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	// -------------------------
	// DIZZINESS (subtle sway)
	// -------------------------
	float wave = sin(
		uv.y * 12.0 +
		time * 1.5
	) * 0.002 * dizziness_intensity;

	uv.x += wave;

	// -------------------------
	// TREMOR
	// -------------------------
	float tremor_x = sin(time * 55.0) * 0.006 * tremor_intensity;
	float tremor_y = cos(time * 47.0) * 0.004 * tremor_intensity;

	uv += vec2(tremor_x, tremor_y);

	// -------------------------
	// SCREEN SAMPLE
	// -------------------------
	vec4 col = texture(screen_texture, uv);

	// -------------------------
	// HEARTBEAT RED PULSE
	// -------------------------
	float pulse = sin(time * 8.0) * 0.5 + 0.5;

	col.rgb += vec3(0.18, 0.0, 0.0)
		* pulse
		* heartbeat_intensity;

	// -------------------------
	// VIGNETTE
	// -------------------------
	float vignette = distance(
		SCREEN_UV,
		vec2(0.5)
	);

	col.rgb *= 1.0
		- vignette
		* 0.65
		* heartbeat_intensity;

	COLOR = col;
}