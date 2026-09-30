extends Node2D

@onready var porta = $"Código"
@onready var tela_codigo = $TelaCodigo
@onready var campo = $TelaCodigo/CampoTexto
@onready var botao = $TelaCodigo/BotaoConfirmar
@onready var mensagem = $TelaCodigo/Mensagem

var ultimo_clique_fora := 0
var tentativas = 3
var reiniciando = false


func _ready():
	tela_codigo.hide()
	mensagem.hide()

	porta.input_pickable = true
	porta.input_event.connect(_clicou_porta)

	botao.pressed.connect(_verificar_codigo)

	# Enter confirma o código
	campo.text_submitted.connect(_codigo_por_enter)


func _clicou_porta(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if Gamemanager.recepcao_resolvida:
				return

			tela_codigo.show()
			campo.clear()
			mensagem.hide()
			campo.grab_focus()
			ultimo_clique_fora = 0


func _input(event):
	if not tela_codigo.visible or reiniciando:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if not botao.get_global_rect().has_point(event.position):
				var agora = Time.get_ticks_msec()

				if agora - ultimo_clique_fora <= 350:
					tela_codigo.hide()
					mensagem.hide()
					ultimo_clique_fora = 0
				else:
					ultimo_clique_fora = agora


func _codigo_por_enter(_texto):
	_verificar_codigo()


func _verificar_codigo():
	if reiniciando:
		return

	var codigo = campo.text.strip_edges().to_lower()

	if codigo == "esquizofrenia":
		Gamemanager.recepcao_resolvida = true
		tela_codigo.hide()
		mensagem.hide()
		ultimo_clique_fora = 0

		Gamemanager.mudar_cena("res://CENAS/final.tscn")

	else:
		tentativas -= 1

		if tentativas > 0:
			mensagem.text = "Código incorreto.\nTentativas restantes: " + str(tentativas)
			mensagem.show()

			campo.clear()
			campo.grab_focus()

		else:
			mensagem.text = "Código incorreto
			Tentativas restantes: 0."
			mensagem.show()

			await get_tree().create_timer(1.0).timeout
			_reiniciar_jogo()


func _reiniciar_jogo():
	reiniciando = true

	var camada_fade = CanvasLayer.new()
	camada_fade.layer = 100
	add_child(camada_fade)

	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	camada_fade.add_child(fade)

	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.5)

	await tween.finished

	Gamemanager.resetar_jogo()
	Gamemanager.iniciar_jogo()
