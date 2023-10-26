shader_type canvas_item;

uniform int player;
uniform bool moved = false;
uniform int outline = 2;

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
			COLOR.rgb =  color * 0.5;
		} else {
			COLOR.rgb = color;
		}
	} else {
		
		int m = outline*4;
		float totalA = 0.0;
		for (int i = 0; i < m; i++) {
			totalA += texture(TEXTURE, UV+(TEXTURE_PIXEL_SIZE*neighbours[i])).a;
		}
		if (totalA > 0.0) {
			COLOR.a = 1.0;
			COLOR.rgb = vec3(0.0);
		}
	}

}
