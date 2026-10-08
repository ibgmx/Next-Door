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

@onready var remedio = $GavetaAberta/Remédio
@onready var papel0 = $GavetaAberta/Papel0
@onready var cloza = $GavetaAberta/Cloza

@onready var boneca = $MalaAberta/Boneca

@onready var dias = $Dias
@onready var travesseiro = $Travesseiro
@onready var texto = $Texto

@onready var som_abrindo_gaveta = $GavetaAberta/Abrindo
@onready var som_fechando_gaveta = $GavetaAberta/Fechando
@onready var som_abrindo_mala = $MalaAberta/Abrindo
@onready var som_fechando_mala = $MalaAberta/Fechando
@onready var camera = $Camera2D
@onready var som_porta_entrada = $SomPortaEntrando

@onready var descricao = $InterfaceDescricao/Descricao


# =========================================================
# TWEENS DAS DESCRIÇÕES
# =========================================================

var tween_descricao: Tween
var coleta_tween: Tween

# Impede que o mouse_exited apague a mensagem
# enquanto o jogador acabou de pegar um item.
var descricao_coleta_ativa := false

var texto_tremendo := false
var camera_posicao_original := Vector2.ZERO
var tween_camera_texto: Tween


# =========================================================
# FADE DE ENTRADA
# =========================================================

var fade_quarto: ColorRect
var tween_fade_quarto: Tween


# =========================================================
# FALAS
# ALTERE AS FALAS AQUI
# =========================================================

var fala_gaveta := "Uma gaveta."
var fala_mala := "Uma mala."

var fala_porta := "A porta parece estar trancada."
var fala_porta_chave := "Uma chave pode abrir algo..."
var fala_porta_aberta := "A porta já está aberta."

var fala_chave := "Essa chave pode abrir algo."
var fala_papel := "Um papel."

var fala_remedio := "O gosto é ruim, mas não lembro de tomar."
var fala_papel0 := "Não enxergo nada"
var fala_cloza := "Czloa? não enxergo bem..."
var fala_boneca := "Que sensação estranha."
var fala_dias := "O que é isso?"
var fala_travesseiro := "É aconchegante."
var fala_texto := "Quem escreveu isso?"


func _ready():

	gaveta_aberta.hide()
	mala_aberta.hide()

	descricao.text = ""
	descricao.modulate.a = 0.0


	# =====================================================
	# OBJETOS CLICÁVEIS
	# =====================================================

	gaveta.input_pickable = true
	mala.input_pickable = true
	porta.input_pickable = true

	chave1.input_pickable = true
	papel.input_pickable = true

	remedio.input_pickable = true
	papel0.input_pickable = true
	cloza.input_pickable = true

	boneca.input_pickable = true

	dias.input_pickable = true
	travesseiro.input_pickable = true
	texto.input_pickable = true

	camera_posicao_original = camera.position


	# =====================================================
	# CLIQUES
	# =====================================================

	gaveta.input_event.connect(_clicou_gaveta)
	mala.input_event.connect(_clicou_mala)

	chave1.input_event.connect(_clicou_chave)
	papel.input_event.connect(_clicou_papel)


	# =====================================================
	# BOTÕES DE FECHAR
	# =====================================================

	botao_gaveta.pressed.connect(_fechar_gaveta)
	botao_mala.pressed.connect(_fechar_mala)


	# =====================================================
	# HOVER
	# =====================================================

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


	# =====================================================
	# NOVOS OBJETOS
	# =====================================================

	remedio.mouse_entered.connect(_mouse_entrou_remedio)
	remedio.mouse_exited.connect(_mouse_saiu)

	papel0.mouse_entered.connect(_mouse_entrou_papel0)
	papel0.mouse_exited.connect(_mouse_saiu)

	cloza.mouse_entered.connect(_mouse_entrou_cloza)
	cloza.mouse_exited.connect(_mouse_saiu)

	boneca.mouse_entered.connect(_mouse_entrou_boneca)
	boneca.mouse_exited.connect(_mouse_saiu)

	dias.mouse_entered.connect(_mouse_entrou_dias)
	dias.mouse_exited.connect(_mouse_saiu)

	travesseiro.mouse_entered.connect(_mouse_entrou_travesseiro)
	travesseiro.mouse_exited.connect(_mouse_saiu)

	texto.mouse_entered.connect(_mouse_entrou_texto)
	texto.mouse_exited.connect(_mouse_saiu)


	# =====================================================
	# VERIFICAR ITENS JÁ COLETADOS
	# =====================================================

	if Inventario.tem_item("chave1"):

		chave1.hide()
		chave1.input_pickable = false


	if Inventario.tem_item("papel"):

		papel.hide()
		papel.input_pickable = false


	# =====================================================
	# FADE DE ENTRADA DO QUARTO
	# =====================================================

	if Gamemanager.quarto_com_fade:

		Gamemanager.quarto_com_fade = false

		_fade_entrada_quarto()


# =========================================================
# FADE DE ENTRADA DO QUARTO
# =========================================================

func _fade_entrada_quarto():

	var camada_fade = CanvasLayer.new()
	camada_fade.layer = 1000

	add_child(camada_fade)


	fade_quarto = ColorRect.new()

	fade_quarto.color = Color.BLACK
	fade_quarto.modulate.a = 1.0

	fade_quarto.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	camada_fade.add_child(fade_quarto)


	tween_fade_quarto = create_tween()

	tween_fade_quarto.tween_property(
		fade_quarto,
		"modulate:a",
		0.0,
		1.5
	)

	await tween_fade_quarto.finished

	camada_fade.queue_free()


# =========================================================
# BLOQUEAR OBJETOS FORA DA GAVETA/MALA
# =========================================================

func bloquear_objetos_externos(bloquear: bool):

	dias.input_pickable = not bloquear
	travesseiro.input_pickable = not bloquear
	texto.input_pickable = not bloquear


# =========================================================
# DESCRIÇÃO
# =========================================================

func mostrar_descricao(texto_descricao: String):

	# Enquanto a mensagem de coleta estiver na tela,
	# o hover não pode substituí-la.
	if descricao_coleta_ativa:
		return

	if tween_descricao and tween_descricao.is_valid():
		tween_descricao.kill()

	descricao.text = texto_descricao
	descricao.show()
	descricao.modulate.a = 1.0


func esconder_descricao():

	# Muito importante:
	# quando um item é escondido depois de ser coletado,
	# o mouse_exited pode ser disparado.
	# Nesse caso, não devemos apagar a mensagem de coleta.
	if descricao_coleta_ativa:
		return

	if tween_descricao and tween_descricao.is_valid():
		tween_descricao.kill()

	tween_descricao = create_tween()

	tween_descricao.tween_property(
		descricao,
		"modulate:a",
		0.0,
		0.15
	)

	tween_descricao.tween_callback(
		descricao.hide
	)


# =========================================================
# GAVETA
# =========================================================

func _clicou_gaveta(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			gaveta_aberta.show()

		if som_abrindo_gaveta:
			som_abrindo_gaveta.stop()
			som_abrindo_gaveta.play()
			mala_aberta.hide()

			gaveta.input_pickable = false
			mala.input_pickable = false
			porta.input_pickable = false

			# BLOQUEIA OS OBJETOS QUE ESTÃO FORA
			bloquear_objetos_externos(true)

			Cursormanager.cursor_normal()


func _fechar_gaveta():

	gaveta_aberta.hide()

	if som_fechando_gaveta:
		som_fechando_gaveta.stop()
		som_fechando_gaveta.play()

	gaveta.input_pickable = true
	mala.input_pickable = true
	porta.input_pickable = true

	# LIBERA OS OBJETOS QUE ESTÃO FORA
	bloquear_objetos_externos(false)

	Cursormanager.cursor_normal()


# =========================================================
# MALA
# =========================================================

func _clicou_mala(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			mala_aberta.show()

		if som_abrindo_mala:
			som_abrindo_mala.stop()
			som_abrindo_mala.play()
			gaveta_aberta.hide()

			gaveta.input_pickable = false
			mala.input_pickable = false
			porta.input_pickable = false

			# BLOQUEIA OS OBJETOS QUE ESTÃO FORA
			bloquear_objetos_externos(true)

			Cursormanager.cursor_normal()


func _fechar_mala():

	mala_aberta.hide()

	if som_fechando_mala:
		som_fechando_mala.stop()
		som_fechando_mala.play()

	gaveta.input_pickable = true
	mala.input_pickable = true
	porta.input_pickable = true

	# LIBERA OS OBJETOS QUE ESTÃO FORA
	bloquear_objetos_externos(false)

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

			_fade_descricao_item()


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

			_fade_descricao_item()


# =========================================================
# FADE AO PEGAR ITEM
# =========================================================

func _fade_descricao_item():

	descricao_coleta_ativa = true

	if tween_descricao and tween_descricao.is_valid():
		tween_descricao.kill()

	if coleta_tween and coleta_tween.is_valid():
		coleta_tween.kill()

	coleta_tween = create_tween()

	# Tempo para conseguir ler.
	coleta_tween.tween_interval(2.0)

	# Fade out.
	coleta_tween.tween_property(
		descricao,
		"modulate:a",
		0.0,
		0.5
	)

	coleta_tween.tween_callback(
		_finalizar_fade_coleta
	)


func _finalizar_fade_coleta():

	descricao_coleta_ativa = false

	descricao.hide()


# =========================================================
# HOVER DA PORTA
# =========================================================

func _mouse_entrou_porta():

	Cursormanager.cursor_clique()

	if Gamemanager.portas_abertas.get("chave1", false):

		mostrar_descricao(fala_porta_aberta)

	elif Inventario.tem_item("chave1"):

		mostrar_descricao(fala_porta_chave)

	else:

		mostrar_descricao(fala_porta)


# =========================================================
# HOVER DA CHAVE
# =========================================================

func _mouse_entrou_chave():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_chave)


# =========================================================
# HOVER DO PAPEL
# =========================================================

func _mouse_entrou_papel():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_papel)


# =========================================================
# HOVER DA GAVETA
# =========================================================

func _mouse_entrou_gaveta():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_gaveta)


# =========================================================
# HOVER DA MALA
# =========================================================

func _mouse_entrou_mala():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_mala)


# =========================================================
# HOVER DO REMÉDIO
# =========================================================

func _mouse_entrou_remedio():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_remedio)


# =========================================================
# HOVER DO PAPEL0
# =========================================================

func _mouse_entrou_papel0():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_papel0)


# =========================================================
# HOVER DA CLOZA
# =========================================================

func _mouse_entrou_cloza():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_cloza)


# =========================================================
# HOVER DA BONECA
# =========================================================

func _mouse_entrou_boneca():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_boneca)


# =========================================================
# HOVER DOS DIAS
# =========================================================

func _mouse_entrou_dias():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_dias)


# =========================================================
# HOVER DO TRAVESSEIRO
# =========================================================

func _mouse_entrou_travesseiro():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_travesseiro)


# =========================================================
# HOVER DO TEXTO
# =========================================================

func _mouse_entrou_texto():

	Cursormanager.cursor_clique()

	mostrar_descricao(fala_texto)

	if texto_tremendo:
		return

	texto_tremendo = true
	_tremer_camera_texto()


func _tremer_camera_texto():

	while texto_tremendo:
		if tween_camera_texto and tween_camera_texto.is_valid():
			tween_camera_texto.kill()

		var deslocamento = Vector2(randf_range(-4.0, 4.0), randf_range(-4.0, 4.0))
		tween_camera_texto = create_tween()
		tween_camera_texto.tween_property(camera, "position", camera_posicao_original + deslocamento, 0.05)
		await tween_camera_texto.finished


# =========================================================
# MOUSE SAIU
# =========================================================

func _mouse_saiu():

	Cursormanager.cursor_normal()

	if texto_tremendo:
		texto_tremendo = false
		if tween_camera_texto and tween_camera_texto.is_valid():
			tween_camera_texto.kill()
		camera.position = camera_posicao_original

	esconder_descricao()
