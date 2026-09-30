extends Node2D


# =========================================================
# ÁREAS 2D
# =========================================================

@onready var quarto = $Quarto
@onready var recepcao = $Recepção
@onready var gaveta = $Gaveta


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


var ultimo_clique_fora := 0


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
	# ÁREAS 2D
	# =====================================================

	quarto.input_pickable = true
	recepcao.input_pickable = true
	gaveta.input_pickable = true

	quarto.input_event.connect(_clicou_quarto)
	recepcao.input_event.connect(_clicou_recepcao)
	gaveta.input_event.connect(_clicou_gaveta)


	# =====================================================
	# BOTÕES
	# =====================================================

	botao_c1.pressed.connect(_fechar_c1)
	botao_c2.pressed.connect(_fechar_c2)
	botao_gaveta.pressed.connect(_fechar_gaveta)


	# =====================================================
	# CURSOR DAS ÁREAS
	# =====================================================

	quarto.mouse_entered.connect(_mouse_entrou)
	quarto.mouse_exited.connect(_mouse_saiu)

	recepcao.mouse_entered.connect(_mouse_entrou)
	recepcao.mouse_exited.connect(_mouse_saiu)

	gaveta.mouse_entered.connect(_mouse_entrou)
	gaveta.mouse_exited.connect(_mouse_saiu)


	# =====================================================
	# CURSOR DOS BOTÕES
	# =====================================================

	botao_c1.mouse_entered.connect(_mouse_entrou)
	botao_c1.mouse_exited.connect(_mouse_saiu)

	botao_c2.mouse_entered.connect(_mouse_entrou)
	botao_c2.mouse_exited.connect(_mouse_saiu)

	botao_gaveta.mouse_entered.connect(_mouse_entrou)
	botao_gaveta.mouse_exited.connect(_mouse_saiu)


	# =====================================================
	# CÓDIGO
	# =====================================================

	botao.pressed.connect(_verificar_codigo)
	campo.text_submitted.connect(_codigo_por_enter)


# =========================================================
# ABRIR C1 - QUARTO
# =========================================================

func _clicou_quarto(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			c1.show()
			c2.hide()
			gaveta_aberta.hide()

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

			Cursormanager.cursor_normal()


# =========================================================
# FECHAR C1
# =========================================================

func _fechar_c1():

	c1.hide()
	Cursormanager.cursor_normal()


# =========================================================
# FECHAR C2
# =========================================================

func _fechar_c2():

	c2.hide()
	Cursormanager.cursor_normal()


# =========================================================
# FECHAR GAVETA
# =========================================================

func _fechar_gaveta():

	gaveta_aberta.hide()
	Cursormanager.cursor_normal()


# =========================================================
# DOIS CLIQUES PARA FECHAR A TELA DE CÓDIGO
# =========================================================

func _input(event):

	if not tela_codigo.visible:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if not botao.get_global_rect().has_point(event.position):

				var agora = Time.get_ticks_msec()

				if agora - ultimo_clique_fora <= 350:

					tela_codigo.hide()
					mensagem.hide()
					campo.clear()

					ultimo_clique_fora = 0

					Cursormanager.cursor_normal()

				else:

					ultimo_clique_fora = agora


# =========================================================
# TENTAR SAIR
# =========================================================

func tentar_sair():

	if Gamemanager.cameras_resolvidas:

		Cursormanager.cursor_normal()

		Gamemanager.mudar_cena(
			"res://CENAS/corredor.tscn"
		)

	else:

		tela_codigo.show()

		campo.clear()
		mensagem.hide()

		campo.grab_focus()

		ultimo_clique_fora = 0


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

		# Sai automaticamente ao acertar
		Gamemanager.mudar_cena(
			"res://CENAS/corredor.tscn"
		)

	else:

		mensagem.text = "Código incorreto."
		mensagem.show()

		campo.clear()
		campo.grab_focus()


# =========================================================
# CURSOR
# =========================================================

func _mouse_entrou():

	Cursormanager.cursor_clique()


func _mouse_saiu():

	Cursormanager.cursor_normal()
