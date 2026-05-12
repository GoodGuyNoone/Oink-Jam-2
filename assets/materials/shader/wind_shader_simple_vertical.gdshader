shader_type spatial;

render_mode cull_disabled, depth_prepass_alpha, blend_mix;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture;

uniform float alpha_cutoff = 0.35;

uniform float wind_strength = 0.18;
uniform float wind_speed = 2.0;
uniform float wind_scale = 1.5;

uniform float edge_power = 1.8;
uniform float vertical_sway = 0.25;
uniform float side_sway = 0.08;

uniform bool invert_edge_mask = false;
uniform bool use_uv_y_for_edge = false;

uniform vec3 wind_direction = vec3(1.0, 0.0, 0.3);

uniform float normal_strength = 1.0;
uniform float roughness_value = 0.8;
uniform bool use_normal_texture = true;
uniform bool use_roughness_texture = false;

void vertex() {
	float edge_value = use_uv_y_for_edge ? UV.y : UV.x;

	if (invert_edge_mask) {
		edge_value = 1.0 - edge_value;
	}

	float edge_mask = pow(edge_value, edge_power);

	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float wave = sin(
		world_pos.x * wind_scale +
		world_pos.z * wind_scale +
		TIME * wind_speed
	);

	float secondary_wave = sin(
		world_pos.x * wind_scale * 2.4 +
		TIME * wind_speed * 1.7
	) * 0.4;

	float wind = wave + secondary_wave;

	vec3 dir = normalize(wind_direction);

	VERTEX.x += dir.x * wind * wind_strength * side_sway * edge_mask;
	VERTEX.z += dir.z * wind * wind_strength * side_sway * edge_mask;

	VERTEX.y += wind * wind_strength * vertical_sway * edge_mask;
}

void fragment() {
vec4 tex = texture(albedo_texture, UV);

ALBEDO = tex.rgb;
ALPHA = tex.a;

ALPHA_SCISSOR_THRESHOLD = 0.35;

	if (use_normal_texture) {
		NORMAL_MAP = texture(normal_texture, UV).rgb;
		NORMAL_MAP_DEPTH = normal_strength;
	}

	if (use_roughness_texture) {
		ROUGHNESS = texture(roughness_texture, UV).r;
	} else {
		ROUGHNESS = roughness_value;
	}
}