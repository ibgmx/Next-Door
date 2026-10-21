shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.05, 0.03, 0.02, 1.0);
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.85;
uniform float band_width : hint_range(0.05, 1.0) = 0.3;
uniform float softness : hint_range(0.01, 0.5) = 0.15;
uniform float speed : hint_range(0.0, 3.0) = 0.4;
uniform float pause : hint_range(0.0, 5.0) = 1.0;
uniform float angle_degrees : hint_range(-90.0, 90.0) = 20.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	// Direção da faixa (inclinação)
	float ang = radians(angle_degrees);
	vec2 dir = vec2(cos(ang), sin(ang));
	float p = dot(UV - 0.5, dir) + 0.5;

	// Progresso 0..1 do movimento, com pausa entre as passadas
	float cycle = 1.0 + pause;
	float t = mod(TIME * speed, cycle);
	float progress = clamp(t, 0.0, 1.0);

	// A faixa começa totalmente fora, de um lado, e termina fora, do outro
	float half_w = band_width * 0.5;
	float center = mix(-half_w - softness, 1.0 + half_w + softness, progress);

	float dist = abs(p - center);
	float shadow = 1.0 - smoothstep(half_w - softness, half_w, dist);

	// Escurece só o texto, sem mexer na transparência
	COLOR = base;
	COLOR.rgb = mix(base.rgb, shadow_color.rgb, shadow * shadow_strength);
}