shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float noise_strength : hint_range(0.0, 1.0) = 0.20;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.15;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.30;
uniform float distortion : hint_range(0.0, 0.02) = 0.003;
uniform float streak_strength : hint_range(0.0, 1.0) = 0.30;
uniform float dust_strength : hint_range(0.0, 1.0) = 0.25;

uniform vec4 tint : source_color = vec4(0.82, 0.80, 0.88, 1.0);


// ============================================================
// HASH
// ============================================================

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);

	return fract(p.x * p.y);
}


// ============================================================
// NOISE
// ============================================================

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(
		mix(a, b, f.x),
		mix(c, d, f.x),
		f.y
	);
}


// ============================================================
// FRAGMENT
// ============================================================

void fragment() {

	vec2 uv = SCREEN_UV;

	float time = TIME;

	// Tamanho da tela.
	// SCREEN_PIXEL_SIZE = 1.0 / tamanho da viewport.
	vec2 viewport_size = 1.0 / SCREEN_PIXEL_SIZE;


	// ========================================================
	// DISTORÇÃO HORIZONTAL
	// ========================================================

	float wave = sin(
		uv.y * 35.0 +
		time * 3.0
	);

	float distortion_amount =
		wave * distortion;

	uv.x += distortion_amount;


	// Pequena instabilidade vertical

	uv.y +=
		sin(time * 1.5) *
		0.0007;


	// ========================================================
	// IMAGEM ORIGINAL
	// ========================================================

	vec3 screen = texture(
		screen_texture,
		uv
	).rgb;


	// ========================================================
	// TONALIDADE CCTV
	// ========================================================

	screen *= tint.rgb;


	// ========================================================
	// SCANLINES
	// ========================================================

	float scanlines = sin(
		uv.y *
		viewport_size.y *
		1.5
	);

	scanlines =
		scanlines * 0.5 +
		0.5;

	screen -=
		scanlines *
		scanline_strength *
		0.12;


	// ========================================================
	// RUÍDO PRINCIPAL
	// ========================================================

	float grain = noise(
		uv *
		viewport_size *
		0.75
		+
		vec2(
			time * 13.0,
			time * 7.0
		)
	);

	grain =
		(grain - 0.5) *
		noise_strength;

	screen += grain;


	// ========================================================
	// GRANULAÇÃO FINA
	// ========================================================

	float fine_noise = hash(
		uv *
		viewport_size
		+
		time * 100.0
	);

	fine_noise =
		(fine_noise - 0.5) *
		0.08;

	screen += fine_noise;


	// ========================================================
	// RISCOS HORIZONTAIS
	// ========================================================

	float line_noise = noise(
		vec2(
			floor(uv.y * 80.0),
			time * 2.0
		)
	);

	float streak =
		step(0.93, line_noise);


	float streak_position =
		fract(
			uv.x * 3.0 +
			noise(
				vec2(
					floor(uv.y * 60.0),
					time
				)
			) * 2.0
		);


	float streak_fade =
		smoothstep(
			0.0,
			0.2,
			streak_position
		)
		*
		smoothstep(
			1.0,
			0.7,
			streak_position
		);


	screen +=
		streak *
		streak_fade *
		streak_strength *
		0.18;


	// ========================================================
	// POEIRA / PEQUENOS PONTOS
	// ========================================================

	vec2 dust_grid =
		floor(
			uv *
			viewport_size /
			3.0
		);


	float dust = hash(
		dust_grid +
		floor(time * 8.0)
	);


	float dust_dot =
		step(0.997, dust);


	screen +=
		dust_dot *
		dust_strength *
		0.5;


	// ========================================================
	// VINHETA
	// ========================================================

	vec2 centered =
		uv -
		vec2(0.5);


	float vignette =
		1.0 -
		smoothstep(
			0.25,
			0.75,
			length(centered)
		);


	screen *=
		mix(
			1.0,
			vignette,
			vignette_strength
		);


	// ========================================================
	// ABERRAÇÃO CROMÁTICA
	// ========================================================

	float aberration = 0.0015;


	float red = texture(
		screen_texture,
		uv + vec2(
			aberration,
			0.0
		)
	).r;


	float blue = texture(
		screen_texture,
		uv - vec2(
			aberration,
			0.0
		)
	).b;


	screen.r =
		mix(
			screen.r,
			red,
			0.35
		);


	screen.b =
		mix(
			screen.b,
			blue,
			0.35
		);


	// ========================================================
	// RESULTADO
	// ========================================================

	COLOR = vec4(
		screen,
		1.0
	);
}