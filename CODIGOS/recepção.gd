extends Node2D


@onready var porta = $"Porta"
@onready var codigo = $"Código"

@onready var cadeira = $Cadeira
@onready var cadeira_aberta = $CadeiraAberta
@onready var cartao = $CadeiraAberta/Cartão
@onready var botao_fechar_cadeira = $CadeiraAberta/BotaoFechar

@onready var tela_codigo = $TelaCodigo
@onready var campo = $TelaCodigo/CampoTexto
@onready var botao = $TelaCodigo/BotaoConfirmar
@onready var mensagem = $TelaCodigo/Mensagem

@onready var descricao = $InterfaceDescricao/Descricao

# ============================================================
# LUZ
# ============================================================

@onready var luz = $Luz
@onready var preto = $Preto


var ultimo_clique_fora := 0
var tentativas := 3
var reiniciando := false

var descricao_tween: Tween
var mensagem_item_ativa := false

var piscando := false


func _ready():

	# ============================================================
	# ESTADO INICIAL
	# ============================================================

	tela_codigo.hide()
	mensagem.hide()

	# CadeiraAberta começa fechada
	cadeira_aberta.hide()


	# ============================================================
	# CADEIRA
	# ============================================================

	cadeira.input_pickable = true

	cadeira.input_event.connect(_clicou_cadeira)
	cadeira.mouse_entered.connect(_mouse_entrou_cadeira)
	cadeira.mouse_exited.connect(_mouse_saiu_cadeira)


	# ============================================================
	# BOTÃO FECHAR DA CADEIRA
	# ============================================================

	botao_fechar_cadeira.mouse_filter = Control.MOUSE_FILTER_STOP

	botao_fechar_cadeira.pressed.connect(_fechar_cadeira)

	botao_fechar_cadeira.mouse_entered.connect(_mouse_entrou_fechar)
	botao_fechar_cadeira.mouse_exited.connect(_mouse_saiu_fechar)


	# ============================================================
	# CARTÃO
	# ============================================================

	cartao.input_pickable = true

	cartao.input_event.connect(_clicou_cartao)
	cartao.mouse_entered.connect(_mouse_entrou_cartao)
	cartao.mouse_exited.connect(_mouse_saiu_cartao)

	# Se o cartão já foi coletado, não aparece novamente
	if Inventario.tem_item("cartao"):
		cartao.hide()
		cartao.input_pickable = false


	# ============================================================
	# PORTA
	# ============================================================

	porta.input_pickable = true

	porta.input_event.connect(_clicou_porta)
	porta.mouse_entered.connect(_mouse_entrou_porta)
	porta.mouse_exited.connect(_mouse_saiu_porta)


	# ============================================================
	# CÓDIGO
	# ============================================================

	codigo.input_pickable = true

	codigo.input_event.connect(_clicou_codigo)
	codigo.mouse_entered.connect(_mouse_entrou_codigo)
	codigo.mouse_exited.connect(_mouse_saiu_codigo)


	# ============================================================
	# SENHA
	# ============================================================

	botao.pressed.connect(_verificar_codigo)

	campo.text_submitted.connect(_codigo_por_enter)


	# ============================================================
	# DESCRIÇÃO
	# ============================================================

	descricao.hide()


	# ============================================================
	# LUZ
	# ============================================================

	preto.hide()

	luz.input_pickable = true

	luz.input_event.connect(_clicou_luz)
	luz.mouse_entered.connect(_mouse_entrou_luz)
	luz.mouse_exited.connect(_mouse_saiu_luz)

	call_deferred("_iniciar_efeitos_luz")


# ============================================================
# BLOQUEAR / LIBERAR FUNDO
# ============================================================

func _desativar_fundo():

	cadeira.input_pickable = false
	porta.input_pickable = false
	codigo.input_pickable = false

	Cursormanager.cursor_normal()


func _ativar_fundo():

	cadeira.input_pickable = true
	porta.input_pickable = true
	codigo.input_pickable = true


# ============================================================
# CADEIRA
# ============================================================

func _clicou_cadeira(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			cadeira_aberta.show()

			_desativar_fundo()

			Cursormanager.cursor_normal()


func _mouse_entrou_cadeira():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma cadeira.")


func _mouse_saiu_cadeira():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# ============================================================
# BOTÃO FECHAR DA CADEIRA
# ============================================================

func _fechar_cadeira():

	cadeira_aberta.hide()

	_ativar_fundo()

	Cursormanager.cursor_normal()


func _mouse_entrou_fechar():

	Cursormanager.cursor_clique()


func _mouse_saiu_fechar():

	Cursormanager.cursor_normal()


# ============================================================
# CARTÃO
# ============================================================

func _clicou_cartao(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("cartao")

			cartao.hide()
			cartao.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_item_pego("Você pegou um cartão.")


func _mouse_entrou_cartao():

	Cursormanager.cursor_clique()

	mostrar_descricao("Um cartão.")


func _mouse_saiu_cartao():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# ============================================================
# PORTA
# ============================================================

func _clicou_porta(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Cursormanager.cursor_normal()

			mostrar_descricao(
				"Talvez você precise abrir em outro lugar."
			)


func _mouse_entrou_porta():

	Cursormanager.cursor_clique()

	mostrar_descricao(
		"Talvez você precise abrir em outro lugar."
	)


func _mouse_saiu_porta():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# ============================================================
# CÓDIGO
# ============================================================

func _clicou_codigo(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if Gamemanager.recepcao_resolvida:
				return

			# Sem cartão
			if not Inventario.tem_item("cartao"):

				mostrar_descricao(
					"Talvez precise de um cartão."
				)

				Cursormanager.cursor_normal()

				return

			# Com cartão
			tela_codigo.show()

			# Esconde imediatamente qualquer descrição
			esconder_descricao()

			campo.clear()
			mensagem.hide()

			campo.grab_focus()

			ultimo_clique_fora = 0

			Cursormanager.cursor_normal()


func _mouse_entrou_codigo():

	Cursormanager.cursor_clique()

	if Inventario.tem_item("cartao"):

		mostrar_descricao(
			"Você pode usar o cartão aqui."
		)

	else:

		mostrar_descricao(
			"Talvez precise de um cartão."
		)


func _mouse_saiu_codigo():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# ============================================================
# DESCRIÇÕES
# ============================================================

func mostrar_descricao(texto: String):

	# Não permite nenhuma descrição enquanto
	# a caixa de código estiver aberta
	if tela_codigo.visible:
		return

	if mensagem_item_ativa:
		return

	if descricao_tween:
		descricao_tween.kill()

	descricao.text = texto
	descricao.modulate.a = 1.0

	descricao.show()


func esconder_descricao():

	if descricao_tween:
		descricao_tween.kill()

	descricao.hide()


# ============================================================
# MENSAGEM DE ITEM COLETADO
# ============================================================

func mostrar_item_pego(texto: String):

	mensagem_item_ativa = true

	if descricao_tween:
		descricao_tween.kill()

	descricao.text = texto
	descricao.modulate.a = 1.0

	descricao.show()

	await get_tree().create_timer(3.0).timeout

	if not is_inside_tree():
		return

	descricao_tween = create_tween()

	descricao_tween.tween_property(
		descricao,
		"modulate:a",
		0.0,
		2.0
	)

	await descricao_tween.finished

	descricao.hide()

	mensagem_item_ativa = false


# ============================================================
# FECHAR TELA DO CÓDIGO
# ============================================================

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

					# Garante que não ficou nenhum texto antigo
					esconder_descricao()

					ultimo_clique_fora = 0

				else:

					ultimo_clique_fora = agora


# ============================================================
# ENTER
# ============================================================

func _codigo_por_enter(_texto):

	_verificar_codigo()


# ============================================================
# VERIFICAR CÓDIGO
# ============================================================

func _verificar_codigo():

	if reiniciando:
		return

	var codigo_digitado = campo.text.strip_edges().to_lower()

	if codigo_digitado == "esquizofrenia":

		Gamemanager.recepcao_resolvida = true

		tela_codigo.hide()
		mensagem.hide()

		esconder_descricao()

		ultimo_clique_fora = 0

		Gamemanager.mudar_cena(
			"res://CENAS/final.tscn"
		)

	else:

		tentativas -= 1

		if tentativas > 0:

			mensagem.text = (
				"Código incorreto.\n"
				+ "Tentativas restantes: "
				+ str(tentativas)
			)

			mensagem.show()

			campo.clear()
			campo.grab_focus()

		else:

			mensagem.text = (
				"Código incorreto.\n"
				+ "Tentativas restantes: 0."
			)

			mensagem.show()

			await get_tree().create_timer(1.0).timeout

			_reiniciar_jogo()


# ============================================================
# EFEITOS DA LUZ
# ============================================================

func _iniciar_efeitos_luz():

	efeito_espera()


# ============================================================
# PISCADAS ALEATÓRIAS NORMAIS
# ============================================================

func efeito_espera():

	while true:

		var espera = randf_range(15.0, 30.0)

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


# ============================================================
# LUZ MANUAL
# ============================================================

func _clicou_luz(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				# Segurou o botão:
				# apaga a luz.
				preto.show()

			else:

				# Soltou o botão:
				# acende a luz novamente.
				preto.hide()


# ============================================================
# CURSOR DA LUZ
# ============================================================

func _mouse_entrou_luz():

	Cursormanager.cursor_clique()


func _mouse_saiu_luz():

	Cursormanager.cursor_normal()


# ============================================================
# REINICIAR JOGO
# ============================================================

func _reiniciar_jogo():

	reiniciando = true

	var camada_fade = CanvasLayer.new()
	camada_fade.layer = 100

	add_child(camada_fade)

	var fade = ColorRect.new()

	fade.color = Color.BLACK
	fade.modulate.a = 0.0

	fade.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	camada_fade.add_child(fade)

	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		1.5
	)

	await tween.finished

	Gamemanager.resetar_jogo()
	Gamemanager.iniciar_jogo()
