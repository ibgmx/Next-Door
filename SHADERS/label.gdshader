shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.96, 0.87, 0.70, 1.0); // bege
uniform float glow_size : hint_range(0.0, 10.0) = 3.0;
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * glow_size;
	vec4 base = texture(TEXTURE, UV);

	// Amostra o alpha ao redor para criar o halo
	float a = 0.0;
	for (int i = 0; i < 16; i++) {
		float ang = float(i) * TAU / 16.0;
		vec2 dir = vec2(cos(ang), sin(ang));
		a += texture(TEXTURE, UV + dir * px).a;
		a += texture(TEXTURE, UV + dir * px * 0.5).a;
	}
	a /= 32.0;

	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
	float glow_alpha = clamp(a * glow_intensity * pulse, 0.0, 1.0);

	// Brilho atrás, texto original por cima
	vec4 glow = vec4(glow_color.rgb, glow_alpha * glow_color.a);
	COLOR = mix(glow, base, base.a);
	COLOR.a = max(base.a, glow.a);
}