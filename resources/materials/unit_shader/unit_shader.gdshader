shader_type canvas_item;

uniform int player;
uniform bool moved = false;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float red = 0.0;
	float green = color.g;
	float blue = 0.0;
	if (!moved) {
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
	} else {
		float a = (color.r+color.g+color.b) / 3.0;
		red = a;
		green  = a;
		blue = a;
	}
	
	COLOR.rgba = vec4(red, green, blue, color.a);

}
