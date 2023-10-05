shader_type canvas_item;

uniform bool player;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (player) {
		COLOR.rgba = vec4(0.0, color.g, 1.0, color.a);
	} else {
		COLOR.rgba = vec4(1.0, color.g, 0.0, color.a);
	}
}
