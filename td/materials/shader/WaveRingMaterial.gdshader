shader_type spatial;
render_mode depth_draw_never;

uniform float wave_count     : hint_range(1, 36, 1) = 8;
uniform vec4  ring_color     : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float ring_radius    : hint_range(0.0, 1.0) = 0.333;
uniform float ring_width     : hint_range(0.0, 0.5) = 0.166;
uniform float inner_strength : hint_range(0.0, 0.2) = 0.016;
uniform float outer_strength : hint_range(0.0, 0.2) = 0.032;
uniform float depth_bias     : hint_range(-100, 100, 1) = 1;
uniform float phase_degrees  : hint_range(-180, 180, 1) = 0;
uniform float wave_degrees   : hint_range(-180, 180, 1) = 0;

void  vertex() {
    VERTEX += depth_bias*0.001 * NORMAL;
}

void fragment() {

    vec2 uv = UV - 0.5;
    
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);
    float wave_outer = cos(wave_count * angle + radians(wave_degrees) + radians(wave_count * phase_degrees) + PI) * outer_strength;
    float wave_inner = cos(wave_count * angle + radians(wave_degrees) + radians(wave_count * phase_degrees)) * inner_strength;
    
    float outer_edge = ring_radius + ring_width * 0.5 + wave_outer;
    float inner_edge = ring_radius - ring_width * 0.5 + wave_inner;
    
    float ring = step(inner_edge, dist) - step(outer_edge, dist);
    
    ALBEDO = ring_color.rgb * ring;
    ALPHA  = ring * ring_color.a;
}