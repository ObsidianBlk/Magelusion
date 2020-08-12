shader_type canvas_item;
render_mode blend_add, unshaded;

// Based heavily on...
// https://www.youtube.com/watch?v=QEaTsz_0o44

uniform float seed = 0.0;
uniform float strength = 1.0;
uniform vec4 color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int octaves = 4;
uniform float speed = 0.5;
uniform float scale_a = 20.0;
uniform float scale_b = 20.0;
uniform vec2 offset = vec2(0.0, 0.0);


float rand(vec2 coord){
	float vx = (sin(seed) - 2.0) * 15.239823472956;
	float vy = (1.0 + sin(seed)) * 87.238742634592;
	float ma = 12367.31276531276;
	float mb = 67273.12836498882;
	return fract(sin(dot(coord, vec2(vx, vy)) * ma) * mb);
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
	COLOR = vec4(color.rgb, motion * strength);
}