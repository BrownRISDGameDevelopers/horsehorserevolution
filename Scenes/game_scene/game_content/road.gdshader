shader_type canvas_item;

varying float x;
varying float y;

void fragment() {
	if (abs(UV.x - 0.5) > 0.3)
		x = (0.5 - abs(UV.x - 0.5))/0.2;
	else x = 1.0;
	if (UV.y < 0.8) y = UV.y/0.8;
	else y = (1.0-UV.y)/0.2;
	COLOR.a = x * y * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
