shader_type canvas_item;
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.5;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a > 0.0) {
		COLOR = vec4(color.rgb, opacity);
	} else {
		COLOR = vec4(0.0);
	}
}
