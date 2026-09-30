extends Node2D


@onready var gaveta = $Gaveta
@onready var mala = $Mala

@onready var gaveta_aberta = $GavetaAberta
@onready var mala_aberta = $MalaAberta

@onready var botao_gaveta = $GavetaAberta/BotaoFechar
@onready var botao_mala = $MalaAberta/BotaoFechar

@onready var porta = $PortaQuarto

@onready var chave1 = $GavetaAberta/Chave1
@onready var papel = $MalaAberta/Papel

@onready var descricao = $InterfaceDescricao/Descricao


var tween_descricao: Tween


func _ready():

	gaveta_aberta.hide()
	mala_aberta.hide()

	descricao.text = ""
	descricao.modulate.a = 0.0


	# OBJETOS CLICÁVEIS

	gaveta.input_pickable = true
	mala.input_pickable = true
	porta.input_pickable = true

	chave1.input_pickable = true
	papel.input_pickable = true


	# CLIQUES

	gaveta.input_event.connect(_clicou_gaveta)
	mala.input_event.connect(_clicou_mala)

	chave1.input_event.connect(_clicou_chave)
	papel.input_event.connect(_clicou_papel)


	# BOTÕES DE FECHAR

	botao_gaveta.pressed.connect(_fechar_gaveta)
	botao_mala.pressed.connect(_fechar_mala)


	# HOVER

	gaveta.mouse_entered.connect(_mouse_entrou_gaveta)
	gaveta.mouse_exited.connect(_mouse_saiu)

	mala.mouse_entered.connect(_mouse_entrou_mala)
	mala.mouse_exited.connect(_mouse_saiu)

	porta.mouse_entered.connect(_mouse_entrou_porta)
	porta.mouse_exited.connect(_mouse_saiu)

	chave1.mouse_entered.connect(_mouse_entrou_chave)
	chave1.mouse_exited.connect(_mouse_saiu)

	papel.mouse_entered.connect(_mouse_entrou_papel)
	papel.mouse_exited.connect(_mouse_saiu)


	# VERIFICAR ITENS JÁ COLETADOS

	if Inventario.tem_item("chave1"):
		chave1.hide()
		chave1.input_pickable = false

	if Inventario.tem_item("papel"):
		papel.hide()
		papel.input_pickable = false


# =========================================================
# DESCRIÇÃO
# =========================================================

func mostrar_descricao(texto: String):

	if tween_descricao and tween_descricao.is_valid():
		tween_descricao.kill()

	descricao.text = texto
	descricao.modulate.a = 1.0


func esconder_descricao():

	if tween_descricao and tween_descricao.is_valid():
		tween_descricao.kill()

	tween_descricao = create_tween()

	tween_descricao.tween_property(
		descricao,
		"modulate:a",
		0.0,
		2.0
	)


# =========================================================
# GAVETA
# =========================================================

func _clicou_gaveta(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			gaveta_aberta.show()
			mala_aberta.hide()

			gaveta.input_pickable = false
			mala.input_pickable = false
			porta.input_pickable = false

			Cursormanager.cursor_normal()


func _fechar_gaveta():

	gaveta_aberta.hide()

	gaveta.input_pickable = true
	mala.input_pickable = true
	porta.input_pickable = true

	Cursormanager.cursor_normal()


# =========================================================
# MALA
# =========================================================

func _clicou_mala(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			mala_aberta.show()
			gaveta_aberta.hide()

			gaveta.input_pickable = false
			mala.input_pickable = false
			porta.input_pickable = false

			Cursormanager.cursor_normal()


func _fechar_mala():

	mala_aberta.hide()

	gaveta.input_pickable = true
	mala.input_pickable = true
	porta.input_pickable = true

	Cursormanager.cursor_normal()


# =========================================================
# PEGAR CHAVE
# =========================================================

func _clicou_chave(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("chave1")

			chave1.hide()
			chave1.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou uma chave.")

			if tween_descricao and tween_descricao.is_valid():
				tween_descricao.kill()

			tween_descricao = create_tween()
			tween_descricao.tween_interval(3.0)
			tween_descricao.tween_property(
				descricao,
				"modulate:a",
				0.0,
				2.0
			)


# =========================================================
# PEGAR PAPEL
# =========================================================

func _clicou_papel(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("papel")

			papel.hide()
			papel.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou um papel.")

			if tween_descricao and tween_descricao.is_valid():
				tween_descricao.kill()

			tween_descricao = create_tween()
			tween_descricao.tween_interval(3.0)
			tween_descricao.tween_property(
				descricao,
				"modulate:a",
				0.0,
				2.0
			)


# =========================================================
# HOVER DA PORTA
# =========================================================

func _mouse_entrou_porta():

	Cursormanager.cursor_clique()

	if Inventario.tem_item("chave1"):
		mostrar_descricao("Uma chave pode abrir algo...")
	else:
		mostrar_descricao("A porta parece estar trancada.")


# =========================================================
# HOVER DA CHAVE
# =========================================================

func _mouse_entrou_chave():

	Cursormanager.cursor_clique()
	mostrar_descricao("Essa chave pode abrir algo.")


# =========================================================
# HOVER DO PAPEL
# =========================================================

func _mouse_entrou_papel():

	Cursormanager.cursor_clique()
	mostrar_descricao("Um papel.")


# =========================================================
# HOVER DA GAVETA
# =========================================================

func _mouse_entrou_gaveta():

	Cursormanager.cursor_clique()
	mostrar_descricao("Uma gaveta.")


# =========================================================
# HOVER DA MALA
# =========================================================

func _mouse_entrou_mala():

	Cursormanager.cursor_clique()
	mostrar_descricao("Uma mala.")


# =========================================================
# MOUSE SAIU
# =========================================================

func _mouse_saiu():

	Cursormanager.cursor_normal()
	esconder_descricao()
