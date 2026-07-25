shader_type spatial;
render_mode unshaded;

uniform float glow_rate = 1.0;
uniform float min_glow = 0.0;
uniform float max_glow = 0.3;

void fragment() {
	float value = sin(TIME * glow_rate);
	ALBEDO = vec3(mix(min_glow, max_glow, value));
}
