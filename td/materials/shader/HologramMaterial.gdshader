shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha;

group_uniforms base_texture;
uniform sampler2D albedo_texture : source_color;
uniform float albedo_alpha : hint_range(0.0, 1.0) = 1.0;

group_uniforms tint_edge;
uniform vec4 tint_color : source_color = vec4(1.0, 0.5, 0.0, 0.5); // #FF8000
uniform vec4 edge_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // #FF0000
uniform float edge_power : hint_range(0.0, 4.0) = 0.5;
uniform float edge_size : hint_range(0.1, 10.0) = 1.0;
uniform float edge_intensity : hint_range(0.0, 10.0) = 1.0;

group_uniforms scanlines;
uniform sampler2D scanline_texture;
uniform vec4 scanline_tint : source_color = vec4(1.0, 0.5, 0.0, 1.0); // #FF8000
uniform float scanline_intensity : hint_range(0.0, 10.0) = 1.0;
uniform float scanline_density : hint_range(0.0, 10.0) = 5.0;
uniform float scanline_thickness : hint_range(0.1, 10.0) = 1.0;
uniform float scanline_spacing : hint_range(0.1, 10.0) = 1.0;
uniform float scanline_angle : hint_range(0.0, 6.283) = 0.0;
uniform float scanline_speed = 0.2;

void fragment() {
    float adjusted_time = mod(TIME, 5.0);
    vec2 fixed_uv = UV;

    vec4 color = texture(albedo_texture, fixed_uv);

    color.a *= albedo_alpha;
    vec4 tinted = mix(color, color * tint_color, tint_color.a);

    float edge = 1.0 - dot(NORMAL, VIEW);
    edge = pow(edge, mix(8.0, 2.0, edge_power));
    edge = smoothstep(0.5 - edge_size * 0.1, 0.5 + edge_size * 0.1, edge);
    vec4 edge_effect = edge * edge_intensity * edge_color;

    vec4 scan = vec4(0.0);
    if (scanline_density > 0.001) {
        //vec2 screen_uv = FRAGCOORD.xy / VIEWPORT_SIZE;
        vec2 screen_uv = UV.xy;
        vec2 dir = vec2(cos(scanline_angle), sin(scanline_angle));
        float scan_pos = (screen_uv.x * dir.x + screen_uv.y * dir.y);
        float spacing = mix(50.0, 10.0, scanline_density / 10.0) * scanline_spacing;
        float time_offset = TIME * scanline_speed;
        float line = fract(scan_pos * spacing + time_offset);
        line = smoothstep(
            0.5 - 0.1 * scanline_thickness,
            0.5 + 0.1 * scanline_thickness,
            abs(line - 0.5)
        );
        scan = vec4(scanline_tint.rgb * line * scanline_intensity, line * scanline_tint.a);
    }

    ALBEDO = tinted.rgb + edge_effect.rgb + scan.rgb;
    ALPHA = max(tinted.a, max(edge_effect.a, scan.a));
}
