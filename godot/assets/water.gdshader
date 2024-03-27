shader_type canvas_item;

uniform vec4 bottom_color : source_color;
uniform vec4 top_color : source_color;

void vertex() {
}

void fragment() {
	float depth = UV.y;
	COLOR = (1.0 - depth) * top_color + depth * bottom_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
