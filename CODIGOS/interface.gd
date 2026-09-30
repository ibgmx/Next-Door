extends CanvasLayer


@onready var botao_voltar = $"BotãoVoltar"

@onready var botao_menu = $"BotaoMenu"

@onready var menu_pausa = $"MenuPausa"

@onready var desfoque = $"MenuPausa/Desfoque"

@onready var botao_reiniciar = $"MenuPausa/Reiniciar"
@onready var botao_continuar = $"MenuPausa/Continuar"
@onready var botao_inicio = $"MenuPausa/Inicio"


var menu_aberto := false


func _ready():

	# =========================
	# BOTÃO VOLTAR
	# =========================

	var cena = get_tree().current_scene.scene_file_path

	if cena.ends_with("quarto.tscn"):
		botao_voltar.visible = false

	elif cena.ends_with("corredor.tscn"):
		botao_voltar.visible = true
		botao_voltar.pressed.connect(voltar_para_quarto)

	elif cena.ends_with("escritório.tscn"):
		botao_voltar.visible = true
		botao_voltar.pressed.connect(tentar_sair_escritorio)

	elif cena.ends_with("câmeras.tscn"):
		botao_voltar.visible = true
		botao_voltar.pressed.connect(tentar_sair_cameras)

	elif cena.ends_with("recepção.tscn"):
		botao_voltar.visible = true
		botao_voltar.pressed.connect(voltar_para_corredor)


	# =========================
	# MENU
	# =========================

	menu_pausa.hide()

	botao_menu.pressed.connect(_alternar_menu)

	botao_reiniciar.pressed.connect(_reiniciar)
	botao_continuar.pressed.connect(_continuar)
	botao_inicio.pressed.connect(_inicio)


	# =========================
	# CURSOR
	# =========================

	botao_menu.mouse_entered.connect(cursor_clique)
	botao_menu.mouse_exited.connect(cursor_normal)

	botao_reiniciar.mouse_entered.connect(cursor_clique)
	botao_reiniciar.mouse_exited.connect(cursor_normal)

	botao_continuar.mouse_entered.connect(cursor_clique)
	botao_continuar.mouse_exited.connect(cursor_normal)

	botao_inicio.mouse_entered.connect(cursor_clique)
	botao_inicio.mouse_exited.connect(cursor_normal)


# =========================================================
# ESC
# =========================================================

func _unhandled_input(event):

	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:

			_alternar_menu()


# =========================================================
# ABRIR / FECHAR
# =========================================================

func _alternar_menu():

	if menu_aberto:
		_continuar()
	else:
		_abrir_menu()


func _abrir_menu():

	menu_aberto = true

	menu_pausa.show()

	# Congela completamente o jogo
	get_tree().paused = true

	Cursormanager.cursor_normal()


func _continuar():

	menu_aberto = false

	menu_pausa.hide()

	get_tree().paused = false

	Cursormanager.cursor_normal()


# =========================================================
# REINICIAR
# =========================================================

func _reiniciar():

	menu_aberto = false

	menu_pausa.hide()

	get_tree().paused = false

	Cursormanager.cursor_normal()

	Gamemanager.resetar_jogo()
	Gamemanager.iniciar_jogo()


# =========================================================
# INÍCIO
# =========================================================

func _inicio():

	menu_aberto = false

	menu_pausa.hide()

	get_tree().paused = false

	Cursormanager.cursor_normal()

	Gamemanager.resetar_jogo()

	Gamemanager.mudar_cena(
		"res://CENAS/menu.tscn"
	)


# =========================================================
# NAVEGAÇÃO
# =========================================================

func voltar_para_quarto():

	Gamemanager.mudar_cena(
		"res://CENAS/quarto.tscn"
	)


func voltar_para_corredor():

	Gamemanager.mudar_cena(
		"res://CENAS/corredor.tscn"
	)


func tentar_sair_escritorio():

	var escritorio = get_tree().current_scene

	if escritorio.has_method("tentar_sair"):
		escritorio.tentar_sair()


func tentar_sair_cameras():

	var cameras = get_tree().current_scene

	if cameras.has_method("tentar_sair"):
		cameras.tentar_sair()


# =========================================================
# CURSOR
# =========================================================

func cursor_clique():

	Cursormanager.cursor_clique()


func cursor_normal():

	Cursormanager.cursor_normal()
