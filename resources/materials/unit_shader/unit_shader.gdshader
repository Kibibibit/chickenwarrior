shader_type canvas_item;

uniform int player;
uniform bool moved = false;

void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;

	if (moved) {
		COLOR.rgb =  color * 0.5;
	} else {
		COLOR.rgb = color;
	}

}
