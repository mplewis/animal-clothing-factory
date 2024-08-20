shader_type canvas_item;

uniform vec4 light_color : source_color;
uniform vec4 dark_color : source_color;


void fragment() {
	COLOR = vec4(mix(dark_color.rgb,light_color.rgb,texture(TEXTURE,UV).r),texture(TEXTURE,UV).a);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
