shader_type canvas_item;

uniform float blur_amount: hint_range(0.0, 1.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV, mix(0.0, 5.0, blur_amount));
}
