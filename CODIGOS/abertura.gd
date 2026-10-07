extends Control

@onready var texto = $Texto
@onready var botao_pular = $BotaoPular

var textos = [
	"Você pode clicar na tela pra interagir com os objetos",
	"O botão de menu e o inventário estão nos cantos superiores da tela",
	"Você pode pegar os itens do inventário e move-los pela tela",
	"Explore com calma.",
	"...",
	"Eu não sei onde estou",
	"Eu não sei quem eu sou",
	"Eu não lembro o que aconteceu",
	"Eu não quero lembrar o que aconteceu."
]

var indice = 0
var pulando := false


func _ready():
	# Estado inicial
	texto.modulate.a = 0.0

	botao_pular.modulate.a = 0.0
	botao_pular.scale = Vector2.ONE

	# Mantém o crescimento centralizado
	botao_pular.pivot_offset = botao_pular.size / 2

	# Conexões
	botao_pular.pressed.connect(_pular)
	botao_pular.mouse_entered.connect(_mouse_entrou_botao)
	botao_pular.mouse_exited.connect(_mouse_saiu_botao)

	# Espera 1 segundo antes de começar tudo
	await get_tree().create_timer(1.0).timeout

	if pulando:
		return

	_mostrar_texto()


func _unhandled_input(event):
	if pulando:
		return

	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and not event.echo:
			_pular()


func _pular():
	if pulando:
		return

	pulando = true

	Cursormanager.cursor_normal()
	Gamemanager.iniciar_jogo()


func _mostrar_texto():
	if pulando:
		return

	# Quando todos os textos terminarem
	if indice >= textos.size():
		await get_tree().create_timer(1.0).timeout

		if pulando:
			return

		Gamemanager.iniciar_jogo()
		return

	# Define o texto
	texto.text = textos[indice]

	# Primeiro texto:
	# botão e texto aparecem juntos.
	if indice == 0:
		var entrada = create_tween()
		entrada.set_parallel(true)

		entrada.tween_property(
			texto,
			"modulate:a",
			1.0,
			1.0
		)

		entrada.tween_property(
			botao_pular,
			"modulate:a",
			1.0,
			1.0
		)

		await entrada.finished

	else:
		# Textos seguintes fazem apenas fade in
		var entrada = create_tween()

		entrada.tween_property(
			texto,
			"modulate:a",
			1.0,
			1.0
		)

		await entrada.finished

	if pulando:
		return

	# Texto permanece visível
	await get_tree().create_timer(2.0).timeout

	if pulando:
		return

	# Fade out do texto
	var saida = create_tween()

	saida.tween_property(
		texto,
		"modulate:a",
		0.0,
		1.0
	)

	await saida.finished

	if pulando:
		return

	indice += 1
	_mostrar_texto()


func _mouse_entrou_botao():
	Cursormanager.cursor_clique()

	var tween = create_tween()

	tween.tween_property(
		botao_pular,
		"scale",
		Vector2(1.06, 1.06),
		0.15
	)


func _mouse_saiu_botao():
	Cursormanager.cursor_normal()

	var tween = create_tween()

	tween.tween_property(
		botao_pular,
		"scale",
		Vector2.ONE,
		0.15
	)
