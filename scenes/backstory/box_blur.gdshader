shader_type canvas_item;

// Blurs whatever is behind this node, inside the shape of TEXTURE's alpha.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_radius = 2.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 0.25);

void fragment() {
	float mask = texture(TEXTURE, UV).a;
	vec3 sum = vec3(0.0);
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			vec2 offset = vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE * blur_radius;
			sum += texture(screen_texture, SCREEN_UV + offset).rgb;
		}
	}
	vec3 blurred = sum / 25.0;
	COLOR = vec4(mix(blurred, tint.rgb, tint.a), mask);
}
