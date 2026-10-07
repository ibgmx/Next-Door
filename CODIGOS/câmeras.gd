extends Node2D


# =========================================================
# ÁREAS 2D
# =========================================================

@onready var quarto = $Quarto
@onready var recepcao = $Recepção
@onready var gaveta = $Gaveta

@onready var papel1 = $Papel1
@onready var papel2 = $Papel2
@onready var cadeira = $Cadeira
@onready var camera_area = $Câmera
@onready var ferro = $Ferro


# =========================================================
# ITENS
# =========================================================

@onready var gravador = $GavetaAberta/Gravador
@onready var codigo4 = $GavetaAberta/Código4
@onready var tradutor = $Tradutor


# =========================================================
# OBJETOS
# =========================================================

@onready var mouse = $Mouse
@onready var luz = $Luz
@onready var preto = $Preto
@onready var som_click = $Click

@onready var chiado_c1 = $C1/Chiado
@onready var chiado_c2 = $C2/Chiado

@onready var som_segurou = $Luz/Segurou
@onready var som_soltou = $Luz/Soltou

@onready var som_abrindo = $GavetaAberta/Abrindo
@onready var som_fechar = $GavetaAberta/Fechando


# =========================================================
# CANVAS
# =========================================================

@onready var c1 = $C1
@onready var c2 = $C2
@onready var gaveta_aberta = $GavetaAberta


# =========================================================
# BOTÕES DE FECHAR
# =========================================================

@onready var botao_c1 = $C1/BotaoFechar
@onready var botao_c2 = $C2/BotaoFechar
@onready var botao_gaveta = $GavetaAberta/BotaoFechar


# =========================================================
# TELA DE CÓDIGO
# =========================================================

@onready var tela_codigo = $TelaCodigo
@onready var campo = $TelaCodigo/CampoTexto
@onready var botao = $TelaCodigo/BotaoConfirmar
@onready var mensagem = $TelaCodigo/Mensagem


# =========================================================
# SOM E CÂMERA
# =========================================================

@onready var som_porta = $SomPorta
@onready var som_porta_saindo = $SomPortaSaindo
@onready var som_porta_entrando = $SomPortaEntrando
@onready var som_ferro = $Ferro/Ferro
@onready var botao_fechar_codigo = $TelaCodigo/BotaoFechar
@onready var camera = $Camera2D


# =========================================================
# DESCRIÇÃO
# =========================================================

@onready var descricao = $InterfaceDescricao/Descricao

var descricao_tween: Tween
var mensagem_item_ativa := false


# =========================================================
# OUTROS
# =========================================================

var ultimo_clique_fora := 0
var piscando := false
var luz_pressionada := false
var luz_aguardando_soltou := false


func _ready():

	# =====================================================
	# COMEÇAM FECHADOS
	# =====================================================

	c1.hide()
	c2.hide()
	gaveta_aberta.hide()

	tela_codigo.hide()
	mensagem.hide()


	# =====================================================
	# ITENS
	# =====================================================

	gravador.input_pickable = true
	codigo4.input_pickable = true
	tradutor.input_pickable = true

	gravador.input_event.connect(_clicou_gravador)
	codigo4.input_event.connect(_clicou_codigo4)
	tradutor.input_event.connect(_clicou_tradutor)

	gravador.mouse_entered.connect(_mouse_entrou_gravador)
	gravador.mouse_exited.connect(_mouse_saiu_gravador)

	codigo4.mouse_entered.connect(_mouse_entrou_codigo4)
	codigo4.mouse_exited.connect(_mouse_saiu_codigo4)

	tradutor.mouse_entered.connect(_mouse_entrou_tradutor)
	tradutor.mouse_exited.connect(_mouse_saiu_tradutor)


	# =====================================================
	# VERIFICAR INVENTÁRIO
	# =====================================================

	if Inventario.tem_item("gravador"):

		gravador.hide()
		gravador.input_pickable = false


	if Inventario.tem_item("codigo4"):

		codigo4.hide()
		codigo4.input_pickable = false


	if Inventario.tem_item("tradutor"):

		tradutor.hide()
		tradutor.input_pickable = false


	# =====================================================
	# ÁREAS 2D
	# =====================================================

	quarto.input_pickable = true
	recepcao.input_pickable = true
	gaveta.input_pickable = true

	papel1.input_pickable = true
	papel2.input_pickable = true
	cadeira.input_pickable = true
	camera_area.input_pickable = true
	ferro.input_pickable = true

	quarto.input_event.connect(_clicou_quarto)
	recepcao.input_event.connect(_clicou_recepcao)
	gaveta.input_event.connect(_clicou_gaveta)


	# =====================================================
	# BOTÕES
	# =====================================================

	botao_c1.pressed.connect(_fechar_c1)
	botao_c2.pressed.connect(_fechar_c2)
	botao_gaveta.pressed.connect(_fechar_gaveta)
	botao_fechar_codigo.pressed.connect(_fechar_tela_codigo)


	# =====================================================
	# CURSOR E DESCRIÇÃO DAS ÁREAS
	# =====================================================

	quarto.mouse_entered.connect(_mouse_entrou_quarto)
	quarto.mouse_exited.connect(_mouse_saiu_quarto)

	recepcao.mouse_entered.connect(_mouse_entrou_recepcao)
	recepcao.mouse_exited.connect(_mouse_saiu_recepcao)

	gaveta.mouse_entered.connect(_mouse_entrou_gaveta)
	gaveta.mouse_exited.connect(_mouse_saiu_gaveta)

	papel1.mouse_entered.connect(_mouse_entrou_papel1)
	papel1.mouse_exited.connect(_mouse_saiu_papel1)

	papel2.mouse_entered.connect(_mouse_entrou_papel2)
	papel2.mouse_exited.connect(_mouse_saiu_papel2)

	cadeira.mouse_entered.connect(_mouse_entrou_cadeira)
	cadeira.mouse_exited.connect(_mouse_saiu_cadeira)

	camera_area.mouse_entered.connect(_mouse_entrou_camera)
	camera_area.mouse_exited.connect(_mouse_saiu_camera)

	ferro.mouse_entered.connect(_mouse_entrou_ferro)
	ferro.mouse_exited.connect(_mouse_saiu_ferro)
	ferro.input_event.connect(_clicou_ferro)


	# =====================================================
	# CURSOR DOS BOTÕES
	# =====================================================

	botao_c1.mouse_entered.connect(_mouse_entrou)
	botao_c1.mouse_exited.connect(_mouse_saiu)

	botao_c2.mouse_entered.connect(_mouse_entrou)
	botao_c2.mouse_exited.connect(_mouse_saiu)

	botao_gaveta.mouse_entered.connect(_mouse_entrou)
	botao_gaveta.mouse_exited.connect(_mouse_saiu)
	botao_fechar_codigo.mouse_entered.connect(_mouse_entrou)
	botao_fechar_codigo.mouse_exited.connect(_mouse_saiu)


	# =====================================================
	# CÓDIGO
	# =====================================================

	botao.pressed.connect(_verificar_codigo)
	campo.text_submitted.connect(_codigo_por_enter)

	chiado_c1.finished.connect(_chiado_c1_terminou)
	chiado_c2.finished.connect(_chiado_c2_terminou)

	if som_segurou:
		som_segurou.finished.connect(_segurou_terminou)


	# =====================================================
	# MOUSE
	# =====================================================

	mouse.input_pickable = true

	mouse.input_event.connect(_clicou_mouse)
	mouse.mouse_entered.connect(_mouse_entrou_mouse)
	mouse.mouse_exited.connect(_mouse_saiu_mouse)


	# =====================================================
	# LUZ
	# =====================================================

	preto.hide()

	luz.input_pickable = true

	luz.input_event.connect(_clicou_luz)
	luz.mouse_entered.connect(_mouse_entrou_luz)
	luz.mouse_exited.connect(_mouse_saiu_luz)

	call_deferred("_iniciar_efeitos_luz")


	# =====================================================
	# ENTRADA PELA PRIMEIRA VEZ
	# =====================================================

	if not Gamemanager.cameras_entrada_feita:

		Gamemanager.cameras_entrada_feita = true

		if som_porta:
			som_porta.stop()
			som_porta.play()
			await som_porta.finished

		_balancar_camera()

	else:

		if som_porta_entrando:
			som_porta_entrando.stop()
			som_porta_entrando.play()

		_balancar_camera()


# =========================================================
# ABRIR C1 - QUARTO
# =========================================================

func _clicou_quarto(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			c1.show()
			c2.hide()
			gaveta_aberta.hide()

			_parar_chiado_c2()
			_tocar_chiado_c1()

			_bloquear_areas_fundo()
			esconder_descricao()

			Cursormanager.cursor_normal()


# =========================================================
# ABRIR C2 - RECEPÇÃO
# =========================================================

func _clicou_recepcao(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			c2.show()
			c1.hide()
			gaveta_aberta.hide()

			_parar_chiado_c1()
			_tocar_chiado_c2()

			_bloquear_areas_fundo()
			esconder_descricao()

			Cursormanager.cursor_normal()


# =========================================================
# ABRIR GAVETA
# =========================================================

func _clicou_gaveta(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			gaveta_aberta.show()

			c1.hide()
			c2.hide()

			_parar_chiado()

			_bloquear_areas_fundo()

			esconder_descricao()

			if som_abrindo:
				som_abrindo.stop()
				som_abrindo.play()

			Cursormanager.cursor_normal()


# =========================================================
# FECHAR C1
# =========================================================

func _fechar_c1():

	c1.hide()

	_parar_chiado_c1()

	_liberar_areas_fundo()

	esconder_descricao()

	Cursormanager.cursor_normal()


# =========================================================
# FECHAR C2
# =========================================================

func _fechar_c2():

	c2.hide()

	_parar_chiado_c2()

	_liberar_areas_fundo()

	esconder_descricao()

	Cursormanager.cursor_normal()


# =========================================================
# FECHAR GAVETA
# =========================================================

func _fechar_gaveta():

	gaveta_aberta.hide()

	_liberar_areas_fundo()

	esconder_descricao()

	if som_fechar:
		som_fechar.stop()
		som_fechar.play()

	Cursormanager.cursor_normal()


# =========================================================
# BLOQUEAR ÁREAS DO FUNDO
# =========================================================

func _bloquear_areas_fundo():

	quarto.input_pickable = false
	recepcao.input_pickable = false
	gaveta.input_pickable = false

	papel1.input_pickable = false
	papel2.input_pickable = false
	cadeira.input_pickable = false
	camera_area.input_pickable = false
	ferro.input_pickable = false

	mouse.input_pickable = false
	luz.input_pickable = false


func _liberar_areas_fundo():

	quarto.input_pickable = true
	recepcao.input_pickable = true
	gaveta.input_pickable = true

	papel1.input_pickable = true
	papel2.input_pickable = true
	cadeira.input_pickable = true
	camera_area.input_pickable = true
	ferro.input_pickable = true

	mouse.input_pickable = true
	luz.input_pickable = true


# =========================================================
# CHIADO DAS CÂMERAS
# =========================================================

func _tocar_chiado_c1():

	if chiado_c1:
		if not chiado_c1.playing:
			chiado_c1.play()


func _tocar_chiado_c2():

	if chiado_c2:
		if not chiado_c2.playing:
			chiado_c2.play()


func _parar_chiado_c1():

	if chiado_c1:
		chiado_c1.stop()


func _parar_chiado_c2():

	if chiado_c2:
		chiado_c2.stop()


func _parar_chiado():

	_parar_chiado_c1()
	_parar_chiado_c2()


func _chiado_c1_terminou():

	if c1.visible:
		chiado_c1.play()


func _chiado_c2_terminou():

	if c2.visible:
		chiado_c2.play()


# =========================================================
# GRAVADOR
# =========================================================

func _clicou_gravador(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("gravador")

			gravador.hide()
			gravador.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_item_pego("Você pegou um gravador.")


func _mouse_entrou_gravador():

	Cursormanager.cursor_clique()

	mostrar_descricao("Um gravador.")


func _mouse_saiu_gravador():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# =========================================================
# CÓDIGO4
# =========================================================

func _clicou_codigo4(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("codigo4")

			codigo4.hide()
			codigo4.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_item_pego("Você pegou um código.")


func _mouse_entrou_codigo4():

	Cursormanager.cursor_clique()

	mostrar_descricao("Um código.")


func _mouse_saiu_codigo4():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# =========================================================
# TRADUTOR
# =========================================================

func _clicou_tradutor(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("tradutor")

			tradutor.hide()
			tradutor.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_item_pego("Você pegou um tradutor.")


func _mouse_entrou_tradutor():

	Cursormanager.cursor_clique()

	mostrar_descricao("Um tradutor.")


func _mouse_saiu_tradutor():

	Cursormanager.cursor_normal()

	if not mensagem_item_ativa:
		esconder_descricao()


# =========================================================
# MENSAGEM DE ITEM PEGO
# =========================================================

func mostrar_item_pego(texto: String):

	if descricao_tween:
		descricao_tween.kill()

	mensagem_item_ativa = true

	descricao.text = texto
	descricao.modulate.a = 1.0
	descricao.show()

	descricao_tween = create_tween()

	# Tempo para ler a mensagem
	descricao_tween.tween_interval(3.0)

	# Fade lento
	descricao_tween.tween_property(
		descricao,
		"modulate:a",
		0.0,
		2.0
	)

	descricao_tween.tween_callback(_finalizar_mensagem_item)


func _finalizar_mensagem_item():

	mensagem_item_ativa = false

	descricao.hide()

	descricao.modulate.a = 1.0


# =========================================================
# DESCRIÇÕES
# =========================================================

func mostrar_descricao(texto: String):

	if descricao_tween:
		descricao_tween.kill()

	mensagem_item_ativa = false

	descricao.text = texto
	descricao.modulate.a = 1.0
	descricao.show()


func esconder_descricao():

	if mensagem_item_ativa:
		return

	if descricao_tween:
		descricao_tween.kill()

	descricao_tween = create_tween()

	descricao_tween.tween_property(
		descricao,
		"modulate:a",
		0.0,
		0.5
	)

	descricao_tween.tween_callback(
		descricao.hide
	)


# =========================================================
# FERRO
# =========================================================

func _clicou_ferro(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if som_ferro:
				som_ferro.stop()
				som_ferro.play()

			Cursormanager.cursor_clique()


# =========================================================
# MOUSE
# =========================================================

func _clicou_mouse(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if som_click:
				som_click.stop()
				som_click.play()

			Cursormanager.cursor_clique()


func _mouse_entrou_mouse():

	Cursormanager.cursor_clique()

	mostrar_descricao("Um mouse.")


func _mouse_saiu_mouse():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - QUARTO
# =========================================================

func _mouse_entrou_quarto():

	Cursormanager.cursor_clique()

	mostrar_descricao("Um quarto.")


func _mouse_saiu_quarto():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - RECEPÇÃO
# =========================================================

func _mouse_entrou_recepcao():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma saída...?")


func _mouse_saiu_recepcao():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - GAVETA
# =========================================================

func _mouse_entrou_gaveta():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma gaveta.")


func _mouse_saiu_gaveta():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - PAPEL1
# =========================================================

func _mouse_entrou_papel1():

	Cursormanager.cursor_clique()

	mostrar_descricao("Não parece importante.")


func _mouse_saiu_papel1():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - PAPEL2
# =========================================================

func _mouse_entrou_papel2():

	Cursormanager.cursor_clique()

	mostrar_descricao("Nada aqui.")


func _mouse_saiu_papel2():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - CADEIRA
# =========================================================

func _mouse_entrou_cadeira():

	Cursormanager.cursor_clique()

	mostrar_descricao("Quem se senta aqui?")


func _mouse_saiu_cadeira():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - CÂMERA
# =========================================================

func _mouse_entrou_camera():

	Cursormanager.cursor_clique()

	mostrar_descricao("Eu estava aqui.")


func _mouse_saiu_camera():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# ÁREA - FERRO
# =========================================================

func _mouse_entrou_ferro():

	Cursormanager.cursor_clique()

	mostrar_descricao("Está quente...")


func _mouse_saiu_ferro():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# LUZ
# =========================================================

func _clicou_luz(_viewport, event, _shape_idx):

	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:

		if luz_pressionada:
			return

		luz_pressionada = true
		luz_aguardando_soltou = false

		preto.show()

		if som_segurou:
			som_segurou.stop()
			som_segurou.play()

	else:

		_luz_soltou()


func _luz_soltou():

	if not luz_pressionada:
		return

	luz_pressionada = false

	# Clique curto: espera o áudio Segurou terminar.
	if som_segurou and som_segurou.playing:

		luz_aguardando_soltou = true

		return

	_finalizar_soltou()


func _segurou_terminou():

	if luz_aguardando_soltou and not luz_pressionada:

		luz_aguardando_soltou = false

		_finalizar_soltou()


func _finalizar_soltou():

	luz_aguardando_soltou = false

	preto.hide()

	if som_soltou:
		som_soltou.stop()
		som_soltou.play()


func _mouse_entrou_luz():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma luz.")


func _mouse_saiu_luz():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# EFEITOS DA LUZ
# =========================================================

func _iniciar_efeitos_luz():

	efeito_espera()


# =========================================================
# PISCADAS ALEATÓRIAS
# =========================================================

func efeito_espera():

	while true:

		# Bem menos frequente que antes.
		var espera = randf_range(18.0, 30.0)

		await get_tree().create_timer(espera).timeout

		if not piscando and not luz_pressionada and not luz_aguardando_soltou:

			_piscar_aleatorio()


func _piscar_aleatorio():

	if piscando:
		return

	piscando = true

	var quantidade = randi_range(2, 5)

	for i in range(quantidade):

		if luz_pressionada or luz_aguardando_soltou:
			break

		var tempo_ligado = randf_range(0.04, 0.18)

		preto.show()

		await get_tree().create_timer(tempo_ligado).timeout

		preto.hide()

		var intervalo = randf_range(0.08, 0.45)

		await get_tree().create_timer(intervalo).timeout


	if not luz_pressionada and not luz_aguardando_soltou:
		preto.hide()

	piscando = false


# =========================================================
# INPUT
# =========================================================

func _input(event):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			if luz_pressionada:
				_luz_soltou()


# =========================================================
# TENTAR SAIR
# =========================================================

func tentar_sair():

	if Gamemanager.cameras_resolvidas:
		_sair_para_corredor()
		return

	# Enquanto as câmeras não foram resolvidas, este botão
	# apenas abre a tela do código. Quem fecha a tela é o
	# BotaoFechar que fica dentro do próprio TelaCodigo.
	if tela_codigo.visible:
		return

	tela_codigo.show()
	campo.clear()
	mensagem.hide()
	campo.grab_focus()
	ultimo_clique_fora = 0
	_bloquear_areas_fundo()
	esconder_descricao()
	Cursormanager.cursor_normal()


func _fechar_tela_codigo():

	if not tela_codigo.visible:
		return

	tela_codigo.hide()
	mensagem.hide()
	campo.clear()
	ultimo_clique_fora = 0
	_liberar_areas_fundo()
	esconder_descricao()
	Cursormanager.cursor_normal()


func _sair_para_corredor():

	_parar_chiado()
	Cursormanager.cursor_normal()

	if som_porta_saindo:
		som_porta_saindo.stop()
		som_porta_saindo.play()

	Gamemanager.mudar_cena(
		"res://CENAS/corredor.tscn"
	)


# =========================================================
# ENTER
# =========================================================

func _codigo_por_enter(_texto):

	_verificar_codigo()


# =========================================================
# VERIFICAR CÓDIGO
# =========================================================

func _verificar_codigo():

	var codigo = campo.text.strip_edges().to_lower()

	var codigo_sem_espacos = codigo.replace(" ", "")


	if codigo_sem_espacos == "18" \
	or codigo_sem_espacos == "18semanas" \
	or codigo_sem_espacos == "dezoito" \
	or codigo_sem_espacos == "dezoitosemanas":

		Gamemanager.cameras_resolvidas = true

		tela_codigo.hide()
		mensagem.hide()

		campo.clear()

		ultimo_clique_fora = 0

		Cursormanager.cursor_normal()

		_sair_para_corredor()

	else:

		mensagem.text = "Código incorreto."
		mensagem.show()

		campo.clear()
		campo.grab_focus()


# =========================================================
# BALANÇAR CÂMERA
# =========================================================

func _balancar_camera():

	var posicao_original = camera.position

	var tween = create_tween()

	tween.tween_property(
		camera,
		"position",
		posicao_original + Vector2(-12, 6),
		0.06
	)

	tween.tween_property(
		camera,
		"position",
		posicao_original + Vector2(10, -7),
		0.06
	)

	tween.tween_property(
		camera,
		"position",
		posicao_original + Vector2(-8, 5),
		0.06
	)

	tween.tween_property(
		camera,
		"position",
		posicao_original + Vector2(6, -4),
		0.06
	)

	tween.tween_property(
		camera,
		"position",
		posicao_original + Vector2(-3, 2),
		0.06
	)

	tween.tween_property(
		camera,
		"position",
		posicao_original,
		0.12
	)


# =========================================================
# CURSOR DOS BOTÕES
# =========================================================

func _mouse_entrou():

	Cursormanager.cursor_clique()


func _mouse_saiu():

	Cursormanager.cursor_normal()
