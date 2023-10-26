shader_type canvas_item;


uniform int health = 10;
uniform int max_health = 10;

uniform vec3 no_health_color: source_color = vec3(1.0,0.0,0.0);
uniform vec3 full_health_color: source_color = vec3(0.0,0.5,1.0);

float lerp(float a, float b, float t) {
	return (1.0-t) * a + (t*b);
}

vec3 lerp_v(vec3 a, vec3 b, float t) {
	return vec3(lerp(a.x,b.x,t), lerp(a.y,b.y,t), lerp(a.z,b.z,t));
}

void fragment() {
	float health_value = float(health)/float(max_health);

	if (UV.x > health_value) {
		COLOR.rgb = vec3(0.0);
	} else {
		COLOR.rgb = lerp_v(no_health_color, full_health_color, health_value);
	}
	
}
