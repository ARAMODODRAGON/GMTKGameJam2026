shader_type canvas_item;

uniform float cutoff: hint_range(0.0, 1.0) = 0.4;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

uniform float blur_amount: hint_range(0.0, 1.0) = 1.0;

uniform sampler2D pointer_texture: source_color, filter_nearest;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV, mix(0.0, 5.0, blur_amount));
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float screen_average = (screen_color.r + screen_color.g + screen_color.b) / 3.0;
	
	vec4 texturecolor = texture(pointer_texture, UV);
	if (texturecolor.a > 0.5) {
		if (screen_average < cutoff) {
			COLOR.rgb = vec3(1.0);
		} else {
			COLOR.rgb = vec3(0.0);
		}
	}
	
}
