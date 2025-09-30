shader_type spatial;
render_mode depth_draw_never;

uniform vec4  dotColor       : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float circleCount    : hint_range(1, 36, 1) = 8;
uniform float ringRadius     : hint_range(0.0, 1.0) = 0.333;
uniform float circleRadius   : hint_range(0.0, 1.0) = 0.166;
uniform float depth_bias     : hint_range(-100, 100, 1) = 2;
uniform float phase_degrees  : hint_range(-180, 180, 1) = 0;
uniform float wave_degrees   : hint_range(-180, 180, 1) = 0;

void  vertex() {
    VERTEX += depth_bias*0.001 * NORMAL;
}

void fragment() {

    vec2 uv = (UV - 0.5) * 2.0;
    
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    float offset = radians(phase_degrees) + radians(wave_degrees/circleCount);
    
    float segmentAngle = 2.0 * PI / circleCount;
    float circleIndex = floor((angle - offset + PI) / segmentAngle);
    float circleCenterAngle = circleIndex * segmentAngle + offset - PI + segmentAngle * 0.5;
    vec2 circleCenter = vec2(cos(circleCenterAngle), sin(circleCenterAngle)) * ringRadius;
    vec2 circleUV = uv - circleCenter;
    
    float circle = 1.0-step(circleRadius, length(circleUV));
    
    ALBEDO = dotColor.rgb * circle;
    ALPHA  = dotColor.a * circle;
}
