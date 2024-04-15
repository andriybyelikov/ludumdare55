shader_type canvas_item;
uniform sampler2D screen_texture: hint_screen_texture;
uniform float r_displacement: hint_range(-30.0, 30.0) = 2.0;
uniform float b_displacement: hint_range(-30.0, 30.0) = -2.0;

uniform float r_displacement_max: hint_range(-30.0, 30.0) = 2.0;
uniform float b_displacement_max: hint_range(-30.0, 30.0) = -2.0;

uniform float size: hint_range(0.0, 2.0)= .5;
uniform float min_lum: hint_range(0.0, 1.0) = 0.0;
uniform float max_lum: hint_range(0.0, 1.0) = 1.0;
uniform float speed: hint_range(0.0, 10.0) = 1.0;

uniform int perdiod: hint_range(0.0, 15.0) = 1;
uniform float duration: hint_range(0.0, 1.0) = 1;

void fragment(){
    vec2 uv = SCREEN_UV;
    float pixel_size_x = SCREEN_PIXEL_SIZE.x;

    float r_disp = r_displacement;
    float b_disp = b_displacement;
    if (int(TIME) % perdiod == 0 && fract(TIME) < duration) {
        r_disp = r_displacement_max*sin(TIME*speed);
        b_disp = b_displacement_max*sin(TIME*speed);
    }

	float r = texture(screen_texture, uv + vec2(pixel_size_x*r_disp)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv + vec2(pixel_size_x*b_disp)).b;

    float darken = length(UV-.5)/size;
	COLOR.rgb = vec3(r, g, b)*smoothstep(min_lum, max_lum, 1.0-darken);
}
