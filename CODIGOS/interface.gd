extends CanvasLayer

@onready var botao_voltar = $"BotãoVoltar"
@onready var botao_menu = $"BotaoMenu"
@onready var botao_inventario = $"BotãoInventário"

@onready var menu_pausa = $"MenuPausa"
@onready var desfoque = $"MenuPausa/Desfoque"
@onready var itens = $"Itens"

@onready var botao_reiniciar = $"MenuPausa/Reiniciar"
@onready var botao_certeza = $"MenuPausa/Certeza"
@onready var botao_continuar = $"MenuPausa/Continuar"
@onready var botao_inicio = $"MenuPausa/Inicio"

var menu_aberto := false
var inventario_aberto := false
var inventario_animando := false
var confirmando_reinicio := false
var reiniciando := false

var altura_inventario := 0.0
var tween_inventario: Tween

# Documentos abertos simultaneamente.
var documentos_abertos: Dictionary = {}
var documento_arrastando: TextureRect = null
var deslocamento_documento := Vector2.ZERO


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	altura_inventario = itens.size.y

	menu_pausa.hide()
	itens.hide()
	itens.clip_contents = true
	itens.size.y = 0.0

	botao_reiniciar.show()
	botao_certeza.hide()

	# Reduz somente o ItemInventario3 para 1/3 do tamanho.
	# Não altera os outros itens.
	var item3 = itens.find_child("ItemInventario3", true, false)

	if item3 is Control:
		item3.scale = Vector2.ONE / 3.0

	var cena = get_tree().current_scene.scene_file_path

	if cena.ends_with("quarto.tscn"):
		botao_voltar.hide()
	elif cena.ends_with("corredor.tscn"):
		botao_voltar.show()
		botao_voltar.pressed.connect(voltar_para_quarto)
	elif cena.ends_with("escritório.tscn"):
		botao_voltar.show()
		botao_voltar.pressed.connect(tentar_sair_escritorio)
	elif cena.ends_with("câmeras.tscn"):
		botao_voltar.show()
		botao_voltar.pressed.connect(tentar_sair_cameras)
	elif cena.ends_with("recepção.tscn"):
		botao_voltar.show()
		botao_voltar.pressed.connect(voltar_para_corredor)

	botao_menu.pressed.connect(_alternar_menu)
	botao_inventario.pressed.connect(_alternar_inventario)

	botao_reiniciar.pressed.connect(_reiniciar)
	botao_certeza.pressed.connect(_confirmar_reinicio)
	botao_continuar.pressed.connect(_continuar)
	botao_inicio.pressed.connect(_inicio)

	botao_voltar.mouse_entered.connect(cursor_clique)
	botao_voltar.mouse_exited.connect(cursor_normal)
	botao_menu.mouse_entered.connect(cursor_clique)
	botao_menu.mouse_exited.connect(cursor_normal)
	botao_inventario.mouse_entered.connect(cursor_clique)
	botao_inventario.mouse_exited.connect(cursor_normal)
	botao_reiniciar.mouse_entered.connect(cursor_clique)
	botao_reiniciar.mouse_exited.connect(cursor_normal)
	botao_certeza.mouse_entered.connect(cursor_clique)
	botao_certeza.mouse_exited.connect(cursor_normal)
	botao_continuar.mouse_entered.connect(cursor_clique)
	botao_continuar.mouse_exited.connect(cursor_normal)
	botao_inicio.mouse_entered.connect(cursor_clique)
	botao_inicio.mouse_exited.connect(cursor_normal)





# =========================================================
# DOCUMENTOS
# =========================================================

func _alternar_documento(item: ItemInventario):
	if item == null or item.imagem_documento == null:
		return

	var chave: int = item.get_instance_id()

	# Clicar novamente fecha apenas esse documento.
	if documentos_abertos.has(chave):
		var documento_existente: TextureRect = documentos_abertos[chave]

		if is_instance_valid(documento_existente):
			documento_existente.queue_free()

		documentos_abertos.erase(chave)
		return

	var documento := TextureRect.new()
	documento.name = "Documento_%s" % item.id_item
	documento.texture = item.imagem_documento
	documento.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	documento.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	documento.mouse_filter = Control.MOUSE_FILTER_STOP
	documento.z_index = 100 + documentos_abertos.size()

	var tamanho_original: Vector2 = item.imagem_documento.get_size()
	var tamanho_tela: Vector2 = get_viewport().get_visible_rect().size
	var limite: Vector2 = tamanho_tela * 0.75

	var fator: float = minf(
		1.0,
		minf(
			limite.x / maxf(1.0, tamanho_original.x),
			limite.y / maxf(1.0, tamanho_original.y)
		)
	)

	documento.size = tamanho_original * fator
	documento.position = (tamanho_tela - documento.size) / 2.0

	add_child(documento)
	documentos_abertos[chave] = documento

	documento.gui_input.connect(
		_ao_interagir_documento.bind(documento)
	)
	documento.mouse_entered.connect(cursor_clique)
	documento.mouse_exited.connect(cursor_normal)


func _ao_interagir_documento(event: InputEvent, documento: TextureRect):
	if not is_instance_valid(documento):
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				documento_arrastando = documento
				deslocamento_documento = (
					documento.get_global_mouse_position()
					- documento.position
				)
				documento.z_index = 1000
				documento.move_to_front()
			else:
				if documento_arrastando == documento:
					documento_arrastando = null

	elif event is InputEventMouseMotion:
		if documento_arrastando == documento:
			documento.position = (
				documento.get_global_mouse_position()
				- deslocamento_documento
			)


func _fechar_todos_documentos():
	for chave in documentos_abertos.keys():
		var documento: TextureRect = documentos_abertos[chave]

		if is_instance_valid(documento):
			documento.queue_free()

	documentos_abertos.clear()
	documento_arrastando = null
	Cursormanager.cursor_normal()


func _fechar_documento():
	_fechar_todos_documentos()


# =========================================================
# FECHAR INVENTÁRIO AO ABRIR INTERAÇÕES
# =========================================================

func fechar_inventario_e_documentos():
	_fechar_todos_documentos()
	_fechar_inventario_imediato()


# =========================================================
# TECLADO
# =========================================================

func _input(event):
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_ESCAPE:
		_alternar_menu()
		get_viewport().set_input_as_handled()

	elif event.keycode == KEY_TAB:
		_alternar_inventario()
		get_viewport().set_input_as_handled()


# =========================================================
# MENU DE PAUSA
# =========================================================

func _alternar_menu():
	if reiniciando:
		return

	if menu_aberto:
		_continuar()
	else:
		_abrir_menu()


func _definir_voltar_ativo(ativo: bool):
	if botao_voltar == null:
		return

	if "disabled" in botao_voltar:
		botao_voltar.disabled = not ativo

	botao_voltar.mouse_filter = (
		Control.MOUSE_FILTER_STOP if ativo
		else Control.MOUSE_FILTER_IGNORE
	)

	if not ativo:
		Cursormanager.cursor_normal()


func _abrir_menu():
	fechar_telas_codigo()
	_resetar_confirmacao()
	fechar_inventario_e_documentos()

	menu_aberto = true
	_definir_voltar_ativo(false)
	menu_pausa.show()
	get_tree().paused = true


func _continuar():
	menu_aberto = false
	_definir_voltar_ativo(true)
	menu_pausa.hide()
	get_tree().paused = false
	_resetar_confirmacao()


# =========================================================
# INVENTÁRIO
# =========================================================

func _alternar_inventario():
	if reiniciando or menu_aberto or inventario_animando:
		return

	if inventario_aberto:
		_fechar_inventario()
	else:
		_abrir_inventario()


func _abrir_inventario():
	inventario_aberto = true
	inventario_animando = true
	itens.show()

	if altura_inventario <= 0.0:
		inventario_animando = false
		return

	if tween_inventario and tween_inventario.is_valid():
		tween_inventario.kill()

	tween_inventario = create_tween()
	tween_inventario.tween_property(
		itens,
		"size:y",
		altura_inventario,
		0.5
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween_inventario.finished.connect(
		_finalizar_animacao_inventario
	)


func _fechar_inventario():
	inventario_aberto = false
	inventario_animando = true

	_fechar_todos_documentos()

	if tween_inventario and tween_inventario.is_valid():
		tween_inventario.kill()

	tween_inventario = create_tween()
	tween_inventario.tween_property(
		itens,
		"size:y",
		0.0,
		0.5
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween_inventario.finished.connect(
		_finalizar_animacao_inventario
	)


func _finalizar_animacao_inventario():
	inventario_animando = false

	if inventario_aberto:
		itens.size.y = altura_inventario
		itens.show()
	else:
		itens.size.y = 0.0
		itens.hide()


func _fechar_inventario_imediato():
	if tween_inventario and tween_inventario.is_valid():
		tween_inventario.kill()

	inventario_aberto = false
	inventario_animando = false
	itens.size.y = 0.0
	itens.hide()


# =========================================================
# FECHAR TELAS DE CÓDIGO
# =========================================================

func fechar_telas_codigo():
	var cena = get_tree().current_scene

	var tela_senha = cena.get_node_or_null("TelaSenha")
	if tela_senha:
		tela_senha.hide()

	var tela_codigo = cena.get_node_or_null("TelaCodigo")
	if tela_codigo:
		tela_codigo.hide()


# =========================================================
# REINICIAR
# =========================================================

func _reiniciar():
	if reiniciando:
		return

	confirmando_reinicio = true
	botao_reiniciar.hide()
	botao_certeza.show()


func _confirmar_reinicio():
	if reiniciando or not confirmando_reinicio:
		return

	reiniciando = true
	menu_aberto = false
	_definir_voltar_ativo(true)

	fechar_inventario_e_documentos()
	menu_pausa.hide()
	get_tree().paused = false
	Cursormanager.cursor_normal()

	var camada_fade = CanvasLayer.new()
	camada_fade.layer = 1000
	camada_fade.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(camada_fade)

	var tela_preta = ColorRect.new()
	tela_preta.color = Color.BLACK
	tela_preta.modulate.a = 0.0
	tela_preta.mouse_filter = Control.MOUSE_FILTER_STOP
	tela_preta.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	camada_fade.add_child(tela_preta)

	var tween = create_tween()
	tween.tween_property(tela_preta, "modulate:a", 1.0, 1.0)
	await tween.finished

	Gamemanager.resetar_jogo()
	Gamemanager.iniciar_jogo()


func _resetar_confirmacao():
	confirmando_reinicio = false
	botao_reiniciar.show()
	botao_certeza.hide()


# =========================================================
# VOLTAR AO INÍCIO
# =========================================================

func _inicio():
	if reiniciando:
		return

	menu_aberto = false
	fechar_inventario_e_documentos()
	menu_pausa.hide()
	get_tree().paused = false
	_resetar_confirmacao()
	Cursormanager.cursor_normal()
	Gamemanager.resetar_jogo()
	get_tree().change_scene_to_file("res://CENAS/início.tscn")


# =========================================================
# NAVEGAÇÃO
# =========================================================

func voltar_para_quarto():
	fechar_inventario_e_documentos()
	Gamemanager.mudar_cena("res://CENAS/quarto.tscn")


func voltar_para_corredor():
	fechar_inventario_e_documentos()
	Gamemanager.mudar_cena("res://CENAS/corredor.tscn")


func tentar_sair_escritorio():
	fechar_inventario_e_documentos()

	var escritorio = get_tree().current_scene

	if escritorio.has_method("tentar_sair"):
		escritorio.tentar_sair()


func tentar_sair_cameras():
	fechar_inventario_e_documentos()

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
