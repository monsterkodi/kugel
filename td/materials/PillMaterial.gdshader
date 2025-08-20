shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, blend_mix, depth_draw_always, cull_disabled;

group_uniforms glass;
uniform float opacity    : hint_range(0.0, 1.0) = 0.0;
uniform float roughness  : hint_range(0.0, 1.0) = 0.25;
uniform float refraction : hint_range(-0.1,0.1,0.001) = 0.02;
uniform float specular   : hint_range(0.0, 1.0) = 0.8;
uniform float fesnel     : hint_range(0.0, 1.0) = 1.0;
uniform float boost      : hint_range(0.0, 0.2) = 0.02;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

void fragment() {

	float VdotN = dot(VIEW, NORMAL);
	float fresn = clamp(SchlickFresnel(VdotN), 0.0, 1.0);

	float a = mix(0.001, 1.0, opacity);
	float a_factor_0 = mix(fresn * fesnel, 1.0, a);
	float a_factor_1 = 0.5 * sqrt(a);
	float a_factor_2 = a_factor_0 + a_factor_1;

	ROUGHNESS = mix(0.1, 0.4, roughness);
	SPECULAR = 0.5 * inversesqrt(1.01-specular);

	vec3 unpacked_normal = NORMAL_MAP;
	unpacked_normal.xy = unpacked_normal.xy * 2.0 - 1.0;
	unpacked_normal.z = sqrt(max(0.0, 1.0 - dot(unpacked_normal.xy, unpacked_normal.xy)));
	vec3 ref_normal = normalize(mix(NORMAL,TANGENT * unpacked_normal.x + BINORMAL * unpacked_normal.y + NORMAL * unpacked_normal.z,NORMAL_MAP_DEPTH));
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
	float ref_amount = 1.0 - opacity;
    vec3 refcontr = vec3(boost);
	ALBEDO = (textureLod(screen_texture,ref_ofs,roughness * 5.0).rgb * ref_amount * EXPOSURE * refcontr)/a_factor_2;
}
