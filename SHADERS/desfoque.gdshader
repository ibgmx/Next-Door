shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blur_strength : hint_range(0.0, 10.0) = 1.0;


void fragment() {
	vec2 pixel = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));

	vec4 cor = vec4(0.0);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(-2.0, -2.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(0.0, -2.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(2.0, -2.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(-2.0, 0.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(2.0, 0.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(-2.0, 2.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(0.0, 2.0) * pixel * blur_strength
	);

	cor += texture(
		SCREEN_TEXTURE,
		SCREEN_UV + vec2(2.0, 2.0) * pixel * blur_strength
	);

	COLOR = cor / 9.0;
}