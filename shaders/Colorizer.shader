shader_type canvas_item;

uniform bool AUTO_REPLACE = false;
uniform bool IGNORE_ALPHA = false;
uniform vec4 COLOR_A : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 COLOR_A_REPLACEMENT : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 COLOR_B : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 COLOR_B_REPLACEMENT : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment(){
	vec4 cc = texture(TEXTURE, UV);
	float a = cc.a;
	if (IGNORE_ALPHA)
		a = 1.0;
		
	if (cc == COLOR_A || AUTO_REPLACE){
		cc = vec4(COLOR_A_REPLACEMENT.xyz, a);
	} else if (cc == COLOR_B){
		cc = vec4(COLOR_B_REPLACEMENT.xyz, a);	
	}
	COLOR = cc;
}