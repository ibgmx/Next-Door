extends Node2D


@onready var gaveta_mesa = $Gavetamesa
@onready var gaveta = $Gaveta


@onready var gaveta_mesa_canvas = $GavetaMesa
@onready var gavetinha_canvas = $Gavetinha
@onready var tela_senha = $TelaSenha


@onready var botao_gaveta_mesa = $GavetaMesa/BotaoFechar
@onready var botao_gavetinha = $Gavetinha/BotaoFechar


@onready var campo = $TelaSenha/CampoTexto
@onready var botao_senha = $TelaSenha/BotaoConfirmar
@onready var botao_fechar_senha = $TelaSenha/BotaoFechar
@onready var mensagem = $TelaSenha/Mensagem


var ultimo_clique_fora := 0


func _ready():

	# Todos começam fechados
	gaveta_mesa_canvas.hide()
	gavetinha_canvas.hide()
	tela_senha.hide()
	mensagem.hide()


	# Áreas 2D
	gaveta_mesa.input_pickable = true
	gaveta.input_pickable = true

	gaveta_mesa.input_event.connect(_clicou_gaveta_mesa)
	gaveta.input_event.connect(_clicou_gaveta)


	# Botões das gavetas
	botao_gaveta_mesa.pressed.connect(_fechar_gaveta_mesa)
	botao_gavetinha.pressed.connect(_fechar_gavetinha)


	# Senha
	botao_senha.pressed.connect(_verificar_senha)
	botao_fechar_senha.pressed.connect(_fechar_tela_senha)

	campo.text_submitted.connect(_senha_por_enter)


	# Cursor
	gaveta_mesa.mouse_entered.connect(_mouse_entrou)
	gaveta_mesa.mouse_exited.connect(_mouse_saiu)

	gaveta.mouse_entered.connect(_mouse_entrou)
	gaveta.mouse_exited.connect(_mouse_saiu)


func _input(event):

	if not tela_senha.visible:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Ignora clique no botão confirmar
			if botao_senha.get_global_rect().has_point(event.position):
				return

			# Ignora clique no botão fechar
			if botao_fechar_senha.get_global_rect().has_point(event.position):
				return

			var agora = Time.get_ticks_msec()

			# Dois cliques rápidos fora dos botões
			if agora - ultimo_clique_fora <= 350:

				tela_senha.hide()
				mensagem.hide()
				campo.clear()

				ultimo_clique_fora = 0

				_desbloquear_cenario()

				Cursormanager.cursor_normal()

			else:

				ultimo_clique_fora = agora


# =========================================================
# GAVETA DA MESA
# =========================================================

func _clicou_gaveta_mesa(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			gaveta_mesa_canvas.show()
			gavetinha_canvas.hide()
			tela_senha.hide()

			_bloquear_cenario()

			Cursormanager.cursor_normal()


# =========================================================
# GAVETINHA
# =========================================================

func _clicou_gaveta(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			gavetinha_canvas.show()
			gaveta_mesa_canvas.hide()
			tela_senha.hide()

			_bloquear_cenario()

			Cursormanager.cursor_normal()


# =========================================================
# FECHAR GAVETA DA MESA
# =========================================================

func _fechar_gaveta_mesa():

	gaveta_mesa_canvas.hide()

	_desbloquear_cenario()

	Cursormanager.cursor_normal()


# =========================================================
# FECHAR GAVETINHA
# =========================================================

func _fechar_gavetinha():

	gavetinha_canvas.hide()

	_desbloquear_cenario()

	Cursormanager.cursor_normal()


# =========================================================
# BLOQUEAR CENÁRIO
# =========================================================

func _bloquear_cenario():

	gaveta_mesa.input_pickable = false
	gaveta.input_pickable = false


# =========================================================
# DESBLOQUEAR CENÁRIO
# =========================================================

func _desbloquear_cenario():

	gaveta_mesa.input_pickable = true
	gaveta.input_pickable = true


# =========================================================
# SETA PARA SAIR
# =========================================================

func tentar_sair():

	if Gamemanager.escritorio_resolvido:

		Cursormanager.cursor_normal()
		Gamemanager.mudar_cena("res://CENAS/corredor.tscn")

		return


	# A senha só aparece ao tentar sair
	tela_senha.show()

	gaveta_mesa_canvas.hide()
	gavetinha_canvas.hide()

	_bloquear_cenario()

	campo.clear()
	mensagem.hide()

	campo.grab_focus()

	ultimo_clique_fora = 0


# =========================================================
# BOTÃO FECHAR DA SENHA
# =========================================================

func _fechar_tela_senha():

	tela_senha.hide()
	mensagem.hide()
	campo.clear()

	ultimo_clique_fora = 0

	_desbloquear_cenario()

	Cursormanager.cursor_normal()


# =========================================================
# ENTER
# =========================================================

func _senha_por_enter(_texto):

	_verificar_senha()


# =========================================================
# VERIFICAR SENHA
# =========================================================

func _verificar_senha():

	var resposta = campo.text.strip_edges().to_lower()

	if resposta == "clozapina":

		Gamemanager.escritorio_resolvido = true

		tela_senha.hide()
		mensagem.hide()
		campo.clear()

		ultimo_clique_fora = 0

		_desbloquear_cenario()

		Cursormanager.cursor_normal()

		Gamemanager.mudar_cena("res://CENAS/corredor.tscn")

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
