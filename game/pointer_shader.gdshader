shader_type canvas_item;

uniform float cutoff: hint_range(0.0, 1.0) = 0.4;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float screen_average = (screen_color.r + screen_color.g + screen_color.b) / 3.0;
	
	if (screen_average < cutoff) {
		COLOR.rgb *= vec3(1.0);
	} else {
		COLOR.rgb *= vec3(0.0);
	}
}