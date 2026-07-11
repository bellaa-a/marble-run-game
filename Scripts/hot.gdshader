shader_type canvas_item;

uniform float amount = 0.0;
uniform vec4 cold_color : source_color = vec4(0.2, 0.5, 1.0, 1.0);

void fragment() {
	float edge = max(
		max(UV.x, 1.0 - UV.x),
		max(UV.y, 1.0 - UV.y)
	);

	float frost = smoothstep(0.7, 1.0, edge);

	COLOR = vec4(
		cold_color.rgb,
		frost * amount
	);
}