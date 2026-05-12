shader_type spatial;
render_mode cull_disabled;

uniform float sway = 1.14;
uniform float sway_ = 0.34;
uniform float sway_pow = 1.3;
uniform float grass_roughness = 0.3;
uniform float sway_noise_sampeling_scale = 0.12;
uniform float sway_time_scale = 0.2;
uniform vec3 sway_dir = vec3(1.0, 0.0, 1.0);
uniform sampler2D sway_noise;
uniform float color_scale = 0.3;
uniform float color_grad_height = -0.5;
uniform vec4 top_color : source_color;
uniform vec4 bot_color : source_color;
uniform vec3 grass_scale = vec3(1.0, 1.0, 1.0);

varying vec3 vert;
varying float curent_wind;

float sclamp(float f, float sc) {
	return clamp(((f - 0.5) * sc) + 0.5, 0.0, 1.0);
}

void vertex() {
	VERTEX *= grass_scale;
	vert = VERTEX;

	NORMAL = vec3(0.0, 1.0, 0.0);

	vec3 sway_dir_local = normalize((MODEL_MATRIX * vec4(sway_dir, 0.0)).xyz);
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	curent_wind = texture(
		sway_noise,
		normalize(sway_dir.xz) * (-TIME * sway_time_scale)
		+ world_vertex.xz * vec2(sway_noise_sampeling_scale)
	).x;

	VERTEX += sway_dir_local * sway * VERTEX.y * sclamp(curent_wind, 1.5);
	VERTEX.y -= sway_ * abs(pow(VERTEX.x, sway_pow));
}

void fragment() {
	float gradient = (vert.y + color_grad_height) * color_scale;

	ALBEDO = mix(bot_color.rgb, top_color.rgb, gradient);

	NORMAL *= FRONT_FACING ? 1.0 : -1.0;

	SPECULAR = 0.5;

	ROUGHNESS = clamp(
		1.0 - (sclamp(curent_wind, 0.8) * grass_roughness),
		0.2,
		1.0
	);
}