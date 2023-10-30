shader_type canvas_item;

uniform int player;
uniform bool moved = false;
uniform int outline = 2;
uniform float outline_alpha = 1.0;

const vec2 neighbours[12] = {
	vec2(1.0, 0.0), 
	vec2(0.0, 1.0), 
	vec2(-1.0, 0.0), 
	vec2(0.0, -1.0),
	vec2(1.0, 1.0),
	vec2(1.0, -1.0),
	vec2(-1.0, 1.0),
	vec2(-1.0, -1.0),
	vec2(2.0, 0.0),
	vec2(-2.0, 0.0),
	vec2(0.0, 2.0),
	vec2(0.0, -2.0)
};

bool approxEquals(float a, float b) {
	return abs(a-b) < 0.0001;
}

void fragment() {
	vec4 colorA = texture(TEXTURE, UV).rgba;
	
	if (colorA.a > 0.0) {
		vec3 color = colorA.rgb;
		
		float red = color.r;
		float green = color.g;
		float blue = color.b;
		
		if (approxEquals(red,green) && approxEquals(green, blue)) {
			
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
			COLOR.rgb =  color * 0.4;
		} else {
			COLOR.rgb = color;
		}
	} else {
		
		int m = outline*4;
		bool outline_pixel = false;
		for (int i = 0; i < m; i++) {
			if (texture(TEXTURE, UV+(TEXTURE_PIXEL_SIZE*neighbours[i])).a >0.0) {
				outline_pixel = true;
				break;
			}
		}
		if (outline_pixel) {
			COLOR.a = outline_alpha;
			COLOR.rgb = vec3(0.0);
		}
	}

}
