shader_type canvas_item;

uniform int player;
uniform bool moved = false;

void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;
	
	float red = color.r;
	float green = color.g;
	float blue = color.b;
	
	if (red == green && green == blue) {
		
		if (player == 0) {
			blue = 1.0;
		} else if (player == 1) {
			red = 1.0;
		} else if (player == 2) {
			green = 1.0;
		}
	}
	
	color = vec3(red, green, blue);

	if (moved) {
		COLOR.rgb =  color * 0.5;
	} else {
		COLOR.rgb = color;
	}

}
