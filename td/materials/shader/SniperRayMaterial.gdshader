shader_type spatial;
render_mode blend_premul_alpha, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx, ambient_light_disabled, fog_disabled, specular_occlusion_disabled;

uniform vec4  albedo    : source_color;
uniform vec4  emission  : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);
uniform float roughness : hint_range(0.0, 1.0);
uniform float specular  : hint_range(0.0, 1.0, 0.01);
uniform float metallic  : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	ALBEDO    = albedo.rgb;
	METALLIC  = metallic;
	SPECULAR  = specular;
	ROUGHNESS = roughness;
	EMISSION  = emission.rgb * emission_energy;
	ALPHA *= albedo.a;
}
