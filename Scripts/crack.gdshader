shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float reveal_y = 1.0; // 0 = hidden, 1 = fully shown

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // UV.y goes 0 (top) → 1 (bottom)
    if (UV.y < reveal_y) {
        discard;
    }

    COLOR = tex;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
