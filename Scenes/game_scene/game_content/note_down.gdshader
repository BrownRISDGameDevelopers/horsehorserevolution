shader_type canvas_item;

varying float x;

void fragment() {
	if (UV.x > 0.1) x = (1.0-UV.x)/0.9;
	else x = UV.x/0.1;
	COLOR.a = x * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
