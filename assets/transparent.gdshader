shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a > 0.0) {
		COLOR = vec4(color.rgb, 0.5);
	} else {
		COLOR = vec4(0.0);
	}
}
