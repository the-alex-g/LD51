shader_type canvas_item;

uniform vec3 color = vec3(1, 1, 1);
uniform float intensity = 0;


void fragment() {
	COLOR = vec4(color.x, color.y, color.x, intensity - distance(UV, vec2(0.5, 0.5)) * intensity * 2.0);
}