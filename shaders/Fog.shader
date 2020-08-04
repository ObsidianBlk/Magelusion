shader_type canvas_item;

// Based heavily on...
// https://www.youtube.com/watch?v=QEaTsz_0o44

uniform vec3 color = vec3(1.0, 1.0, 1.0);
uniform int octaves = 4;
uniform float speed = 0.5;
uniform float scale_a = 20.0;
uniform float scale_b = 20.0;
uniform vec2 offset = vec2(0.0, 0.0);

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(15.342, 12.33)) * 1000.0) * 1000.0);
}

// Perlin
float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, cubic.x) + ((c - a) * cubic.y * (1.0 - cubic.x)) + ((d - b) * cubic.x * cubic.y);
}

// Fractal Brownian Motion
float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < octaves; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment(){
	vec2 coord = (UV + offset);
	float motion = fbm((coord*scale_b) + fbm((coord*scale_a) + (TIME * speed)));
	COLOR = vec4(color, motion);
}

void light(){
	LIGHT.a = 1.0 - LIGHT.a;
}