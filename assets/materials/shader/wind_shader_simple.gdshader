shader_type spatial;

render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture;
uniform vec4 albedo_tint : source_color = vec4(1.0);

uniform float wind_strength = 0.15;
uniform float wind_speed = 1.5;
uniform float wind_scale = 1.2;

uniform float stem_stiffness = 1.0;
uniform float flower_sway = 1.4;

uniform float normal_strength = 1.0;
uniform float roughness_value = 0.8;
uniform bool use_normal_texture = true;
uniform bool use_roughness_texture = false;

void vertex() {
	float height_mask = clamp(VERTEX.y * stem_stiffness, 0.0, 1.0);

	float world_noise = sin(
		(MODEL_MATRIX[3].x + VERTEX.x) * wind_scale +
		(MODEL_MATRIX[3].z + VERTEX.z) * wind_scale +
		TIME * wind_speed
	);

	float secondary_noise = sin(
		(MODEL_MATRIX[3].x + VERTEX.x) * wind_scale * 2.3 +
		TIME * wind_speed * 1.7
	) * 0.4;

	float wind = world_noise + secondary_noise;

	VERTEX.x += wind * wind_strength * height_mask;
	VERTEX.z += cos(TIME * wind_speed + MODEL_MATRIX[3].z) * wind_strength * 0.35 * height_mask;

	// Extra motion near flower head/top
	VERTEX.x += wind * wind_strength * flower_sway * pow(height_mask, 2.0);
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