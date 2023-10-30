shader_type canvas_item;


uniform float health = 0.0;
uniform float lost_health = 0.0;
uniform int width = 32;
uniform int height = 4;
uniform float delta = 0.0;

uniform vec3 no_health_color: source_color = vec3(1.0,0.0,0.0);
uniform vec3 full_health_color: source_color = vec3(0.0,0.5,1.0);



float lerp(float a, float b, float t) {
	return (1.0-t) * a + (t*b);
}

vec3 lerp_v(vec3 a, vec3 b, float t) {
	return vec3(lerp(a.x,b.x,t), lerp(a.y,b.y,t), lerp(a.z,b.z,t));
}

void fragment() {
	
	float px = 1.0/float(width);
	float py = 1.0/float(height);
	
	if (UV.x < px || UV.x > 1.0-px || UV.y < py || UV.y > 1.0-py) {
		COLOR.rgb = vec3(0.0);
	} else if (UV.x > health) {
		COLOR.rgb = vec3(0.0);
	} else if (UV.x > health-lost_health && UV.x < health) {
		COLOR.rgb = lerp_v(vec3(0.0), vec3(1.0), delta);
	} else {
		COLOR.rgb = lerp_v(no_health_color, full_health_color, health);
	}
}
