extends Node2D


@onready var quadro_chao = $QuadroChao
@onready var quadro = $Quadro
@onready var frente = $Quadro/ImagemFrente
@onready var tras = $Quadro/ImagemTras
@onready var botao_girar = $Quadro/BotaoGirar
@onready var botao_fechar = $Quadro/BotaoFechar

@onready var luz = $Luz
@onready var preto = $Preto


var quadro_virado := false
var girando := false
var piscando := false


func _ready():

	# =========================
	# QUADRO
	# =========================

	quadro.hide()
	tras.hide()

	frente.pivot_offset = frente.size / 2
	tras.pivot_offset = tras.size / 2

	quadro_chao.input_pickable = true

	quadro_chao.input_event.connect(_clicou_quadro)

	botao_girar.pressed.connect(_girar_quadro)
	botao_fechar.pressed.connect(_fechar_quadro)

	quadro_chao.mouse_entered.connect(_mouse_entrou_quadro)
	quadro_chao.mouse_exited.connect(_mouse_saiu_quadro)

	botao_girar.mouse_entered.connect(_mouse_entrou_girar)
	botao_girar.mouse_exited.connect(_mouse_saiu_girar)

	botao_fechar.mouse_entered.connect(_mouse_entrou_fechar)
	botao_fechar.mouse_exited.connect(_mouse_saiu_fechar)


	# =========================
	# LUZ
	# =========================

	preto.hide()

	luz.input_pickable = true

	luz.input_event.connect(_clicou_luz)

	luz.mouse_entered.connect(_mouse_entrou_luz)
	luz.mouse_exited.connect(_mouse_saiu_luz)


	# Espera a cena terminar de carregar
	call_deferred("_iniciar_efeitos_luz")


# =========================================================
# EFEITOS DA LUZ
# =========================================================

func _iniciar_efeitos_luz():

	# Piscada especial quando entra no corredor vindo do quarto
	if Gamemanager.corredor_vindo_do_quarto:

		# Consome o sinal para não repetir infinitamente
		Gamemanager.corredor_vindo_do_quarto = false

		_piscar_entrada()

	# Efeito aleatório periódico
	efeito_espera()


func _piscar_entrada():

	if piscando:
		return

	piscando = true

	var tempo_restante := 5.0

	while tempo_restante > 0.0:

		var quantidade = randi_range(2, 8)

		for i in range(quantidade):

			if tempo_restante <= 0.0:
				break

			var ligado = randf_range(0.04, 0.18)
			ligado = min(ligado, tempo_restante)

			preto.show()

			await get_tree().create_timer(ligado).timeout

			tempo_restante -= ligado

			if tempo_restante <= 0.0:
				break

			preto.hide()

			var intervalo = randf_range(0.03, 0.35)
			intervalo = min(intervalo, tempo_restante)

			await get_tree().create_timer(intervalo).timeout

			tempo_restante -= intervalo


		if tempo_restante > 0.0:

			var pausa = randf_range(0.05, 0.4)
			pausa = min(pausa, tempo_restante)

			await get_tree().create_timer(pausa).timeout

			tempo_restante -= pausa


	preto.hide()
	piscando = false


func efeito_espera():

	while true:

		var espera = randf_range(8.0, 12.0)

		await get_tree().create_timer(espera).timeout

		if not piscando:
			_piscar_aleatorio()


func _piscar_aleatorio():

	if piscando:
		return

	piscando = true

	var quantidade = randi_range(2, 8)

	var tempo_total := 0.0
	var limite := 5.0

	for i in range(quantidade):

		if tempo_total >= limite:
			break

		var tempo_ligado = randf_range(0.03, 0.20)
		var tempo_intervalo = randf_range(0.03, 0.45)

		if tempo_total + tempo_ligado > limite:
			tempo_ligado = limite - tempo_total

		if tempo_ligado <= 0.0:
			break

		preto.show()

		await get_tree().create_timer(tempo_ligado).timeout

		tempo_total += tempo_ligado

		preto.hide()

		if tempo_total >= limite:
			break

		if tempo_total + tempo_intervalo > limite:
			tempo_intervalo = limite - tempo_total

		if tempo_intervalo <= 0.0:
			break

		await get_tree().create_timer(tempo_intervalo).timeout

		tempo_total += tempo_intervalo


	preto.hide()
	piscando = false


# =========================================================
# QUADRO
# =========================================================

func _clicou_quadro(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Cursormanager.cursor_normal()

			abrir_quadro()


func abrir_quadro():

	quadro.show()


func _fechar_quadro():

	quadro.hide()

	Cursormanager.cursor_normal()


func _girar_quadro():

	if girando:
		return

	girando = true

	var imagem_atual = frente if not quadro_virado else tras
	var nova_imagem = tras if not quadro_virado else frente

	var tween = create_tween()

	tween.tween_property(
		imagem_atual,
		"scale:x",
		0.0,
		0.3
	)

	await tween.finished

	imagem_atual.hide()

	nova_imagem.show()
	nova_imagem.scale.x = 0.0

	var tween_volta = create_tween()

	tween_volta.tween_property(
		nova_imagem,
		"scale:x",
		1.0,
		0.3
	)

	await tween_volta.finished

	quadro_virado = !quadro_virado
	girando = false


# =========================================================
# LUZ MANUAL
# =========================================================

func _clicou_luz(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				preto.show()
			else:
				preto.hide()


# =========================================================
# CURSOR
# =========================================================

func _mouse_entrou_quadro():
	Cursormanager.cursor_clique()


func _mouse_saiu_quadro():
	Cursormanager.cursor_normal()


func _mouse_entrou_girar():
	Cursormanager.cursor_clique()


func _mouse_saiu_girar():
	Cursormanager.cursor_normal()


func _mouse_entrou_fechar():
	Cursormanager.cursor_clique()


func _mouse_saiu_fechar():
	Cursormanager.cursor_normal()


func _mouse_entrou_luz():
	Cursormanager.cursor_clique()


func _mouse_saiu_luz():
	Cursormanager.cursor_normal()
