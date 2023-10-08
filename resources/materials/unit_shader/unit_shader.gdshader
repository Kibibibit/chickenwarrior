shader_type canvas_item;

uniform int player;
uniform bool moved = false;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float player_f;
	float red = 0.0;
	float green = color.g;
	float blue = 0.0;
	if (player == 0) {
		red = 0.0;
		blue = color.b;
	} else if (player == 1) {
		red = 1.0;
		blue = 0.0;
		green = 0.1;
	} else {
		red = 0.0;
		blue = 0.1;
		green = 0.8;
	}
	
	COLOR.rgba = vec4(red, green, blue, color.a);

}
