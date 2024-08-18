shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float normalized_time = 0;
uniform vec4 tint = vec4(1, 0, 0, 1);
uniform bool active = false;

void fragment() {

	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = mix(tex_color, tint, normalized_time);
	
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
