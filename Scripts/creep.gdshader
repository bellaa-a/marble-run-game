shader_type canvas_item;

uniform float amount = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float dist = distance(UV, vec2(0.5));

	float darkness = smoothstep(
		0.3,
		0.8,
		dist
	);

	COLOR = mix(
		tex,
		vec4(0,0,0,1),
		darkness * amount
	);
}