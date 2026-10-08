extends Node2D


@onready var quadro_chao = $QuadroChao
@onready var quadro = $Quadro
@onready var frente = $Quadro/ImagemFrente
@onready var tras = $Quadro/ImagemTras
@onready var chave2 = $Quadro/Chave2
@onready var botao_girar = $Quadro/BotaoGirar
@onready var botao_fechar = $Quadro/BotaoFechar

@onready var luz = $Luz
@onready var preto = $Preto
@onready var som_fechando = $Fechando
@onready var som_luz_segurou = $Luz/Segurou
@onready var som_luz_soltou = $Luz/Soltou

@onready var descricao = $InterfaceDescricao/Descricao
@onready var portas = $Portas
@onready var nicole = $Nicole
@onready var area_043 = $Quadro/Código


# =========================================================
# QUADRO
# =========================================================

var quadro_virado := false
var girando := false


# =========================================================
# LUZ
# =========================================================

var piscando := false
var luz_pressionada := false
var luz_aguardando_soltou := false


# =========================================================
# DESCRIÇÕES
# =========================================================

var descricao_tween: Tween
var coleta_tween: Tween

# Impede que mouse_exited apague a mensagem
# enquanto o jogador acabou de pegar um item.
var descricao_coleta_ativa := false


# =========================================================
# READY
# =========================================================

func _ready():

	# =====================================================
	# QUADRO
	# =====================================================

	quadro.hide()
	tras.hide()

	chave2.hide()
	chave2.input_pickable = false

	frente.pivot_offset = frente.size / 2
	tras.pivot_offset = tras.size / 2


	# =====================================================
	# CHAVE2
	# =====================================================

	chave2.reparent(tras, true)

	tras.mouse_filter = Control.MOUSE_FILTER_IGNORE

	chave2.z_index = 10

	quadro_chao.input_pickable = true

	quadro_chao.input_event.connect(_clicou_quadro)
	chave2.input_event.connect(_clicou_chave2)

	botao_girar.pressed.connect(_girar_quadro)
	botao_fechar.pressed.connect(_fechar_quadro)

	quadro_chao.mouse_entered.connect(_mouse_entrou_quadro)
	quadro_chao.mouse_exited.connect(_mouse_saiu_quadro)

	botao_girar.mouse_entered.connect(_mouse_entrou_girar)
	botao_girar.mouse_exited.connect(_mouse_saiu_girar)

	botao_fechar.mouse_entered.connect(_mouse_entrou_fechar)
	botao_fechar.mouse_exited.connect(_mouse_saiu_fechar)

	chave2.mouse_entered.connect(_mouse_entrou_chave2)
	chave2.mouse_exited.connect(_mouse_saiu_chave2)

	area_043.input_pickable = false
	area_043.input_event.connect(_clicou_043)
	area_043.mouse_entered.connect(_mouse_entrou_043)
	area_043.mouse_exited.connect(_mouse_saiu_043)


	# =====================================================
	# VERIFICAR CHAVE2
	# =====================================================

	if Inventario.tem_item("chave2"):

		chave2.hide()
		chave2.input_pickable = false


	# =====================================================
	# PORTAS
	# =====================================================

	for porta in portas.get_children():

		if porta is Area2D:

			porta.mouse_entered.connect(
				_mouse_entrou_porta.bind(porta)
			)

			porta.mouse_exited.connect(
				_mouse_saiu_porta
			)


	# =====================================================
	# NICOLE
	# =====================================================

	nicole.mouse_entered.connect(_mouse_entrou_nicole)
	nicole.mouse_exited.connect(_mouse_saiu_nicole)


	# =====================================================
	# LUZ
	# =====================================================

	preto.hide()

	luz.input_pickable = true

	luz.input_event.connect(_clicou_luz)
	luz.mouse_entered.connect(_mouse_entrou_luz)
	luz.mouse_exited.connect(_mouse_saiu_luz)

	if som_luz_segurou:
		som_luz_segurou.finished.connect(_segurou_terminou)


	# Espera a cena terminar de carregar.
	call_deferred("_iniciar_efeitos_luz")


# =========================================================
# DESCRIÇÕES
# =========================================================

func mostrar_descricao(texto: String):

	# Se o jogador acabou de pegar um item,
	# não deixa o hover substituir a mensagem.
	if descricao_coleta_ativa:
		return

	if descricao_tween and descricao_tween.is_valid():
		descricao_tween.kill()

	descricao.text = texto
	descricao.show()
	descricao.modulate.a = 1.0


func esconder_descricao():

	# Quando um item some, mouse_exited pode ser chamado.
	# Não queremos que isso apague a mensagem de coleta.
	if descricao_coleta_ativa:
		return

	if descricao_tween and descricao_tween.is_valid():
		descricao_tween.kill()

	descricao_tween = create_tween()

	descricao_tween.tween_property(
		descricao,
		"modulate:a",
		0.0,
		0.15
	)

	descricao_tween.tween_callback(
		descricao.hide
	)


# =========================================================
# FADE DE ITEM COLETADO
# =========================================================

func _fade_descricao_item():

	descricao_coleta_ativa = true

	if descricao_tween and descricao_tween.is_valid():
		descricao_tween.kill()

	if coleta_tween and coleta_tween.is_valid():
		coleta_tween.kill()

	coleta_tween = create_tween()

	# Tempo para o jogador conseguir ler.
	coleta_tween.tween_interval(2.0)

	# Fade lento.
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
# PORTAS
# =========================================================

func _mouse_entrou_porta(porta):

	Cursormanager.cursor_clique()

	# RECEPÇÃO
	if porta.name.to_lower().contains("recep"):

		if Gamemanager.portas_abertas.get("recepcao", false):
			mostrar_descricao("Porta Desbloqueada")
		else:
			mostrar_descricao("Trancada pela segurança.")

		return

	var chave = porta.chave_necessaria

	if Gamemanager.portas_abertas.get(chave, false):

		mostrar_descricao("Está aberta.")

	elif chave != "" and Inventario.tem_item(chave):

		mostrar_descricao("Essa porta pode ser aberta.")

	else:

		mostrar_descricao("Está trancada...")


func _mouse_saiu_porta():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# NICOLE
# =========================================================

func _mouse_entrou_nicole():

	Cursormanager.cursor_clique()

	mostrar_descricao("Que macabro...")


func _mouse_saiu_nicole():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# EFEITOS DA LUZ
# =========================================================

func _iniciar_efeitos_luz():

	# Fechando toca SEMPRE que o corredor é carregado,
	# independentemente de onde o jogador veio.
	if som_fechando:
		som_fechando.stop()
		som_fechando.play()

	# =====================================================
	# PISCAR ESPECIAL AO VOLTAR DO QUARTO
	# =====================================================

	if Gamemanager.corredor_vindo_do_quarto:

		Gamemanager.corredor_vindo_do_quarto = false

		_piscar_entrada()


	# =====================================================
	# PISCAR ESPECIAL AO VOLTAR DO ESCRITÓRIO
	# =====================================================

	elif Gamemanager.corredor_vindo_do_escritorio:

		Gamemanager.corredor_vindo_do_escritorio = false

		_piscar_entrada()


	# =====================================================
	# PISCAR ESPECIAL AO VOLTAR DAS CÂMERAS
	# =====================================================

	elif Gamemanager.corredor_vindo_das_cameras:

		Gamemanager.corredor_vindo_das_cameras = false

		_piscar_entrada()


	# =====================================================
	# PISCADAS ALEATÓRIAS NORMAIS
	# =====================================================

	efeito_espera()


# =========================================================
# PISCAR DE ENTRADA
# =========================================================

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


# =========================================================
# PISCAR ALEATÓRIO NORMAL
# =========================================================

func efeito_espera():

	while true:

		# Agora demora bastante mais entre uma piscada
		# e outra.
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


# =========================================================
# BLOQUEAR OBJETOS DO FUNDO
# =========================================================

func bloquear_objetos_fundo(bloquear: bool):

	for porta in portas.get_children():

		if porta is Area2D:

			porta.input_pickable = not bloquear

	nicole.input_pickable = not bloquear
	luz.input_pickable = not bloquear


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
	area_043.input_pickable = quadro_virado

	bloquear_objetos_fundo(true)


func _fechar_quadro():

	quadro.hide()
	area_043.input_pickable = false

	bloquear_objetos_fundo(false)

	if not Inventario.tem_item("chave2"):

		chave2.hide()
		chave2.input_pickable = false

	Cursormanager.cursor_normal()


# =========================================================
# GIRAR QUADRO
# =========================================================

func _girar_quadro():

	if girando:
		return

	girando = true

	var imagem_atual = frente if not quadro_virado else tras
	var nova_imagem = tras if not quadro_virado else frente


	# =====================================================
	# PRIMEIRA METADE
	# =====================================================

	var tween = create_tween()

	tween.tween_property(
		imagem_atual,
		"scale:x",
		0.0,
		0.3
	)

	await tween.finished


	imagem_atual.hide()


	# =====================================================
	# TROCA DE LADO
	# =====================================================

	nova_imagem.show()

	nova_imagem.scale.x = 0.0
	area_043.input_pickable = (nova_imagem == tras)


	if not quadro_virado and not Inventario.tem_item("chave2"):

		chave2.show()
		chave2.input_pickable = false


	# =====================================================
	# SEGUNDA METADE
	# =====================================================

	var tween_volta = create_tween()

	tween_volta.tween_property(
		nova_imagem,
		"scale:x",
		1.0,
		0.3
	)

	await tween_volta.finished


	# =====================================================
	# FINALIZAÇÃO
	# =====================================================

	if quadro_virado:

		chave2.hide()
		chave2.input_pickable = false

	else:

		if not Inventario.tem_item("chave2"):

			chave2.show()
			chave2.input_pickable = true


	quadro_virado = !quadro_virado
	area_043.input_pickable = quadro_virado
	girando = false


func _clicou_043(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Cursormanager.cursor_normal()
			mostrar_descricao("Há algo escrito no quadro.")


func _mouse_entrou_043():

	Cursormanager.cursor_clique()
	mostrar_descricao("Há algo escrito no quadro.")


func _mouse_saiu_043():

	Cursormanager.cursor_normal()
	esconder_descricao()


# =========================================================
# PEGAR CHAVE2
# =========================================================

func _clicou_chave2(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("chave2")

			chave2.hide()
			chave2.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou uma chave.")

			_fade_descricao_item()


# =========================================================
# HOVER DA CHAVE2
# =========================================================

func _mouse_entrou_chave2():

	Cursormanager.cursor_clique()

	mostrar_descricao("Essa chave pode abrir algo.")


func _mouse_saiu_chave2():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# HOVER DO QUADRO
# =========================================================

func _mouse_entrou_quadro():

	Cursormanager.cursor_clique()

	mostrar_descricao("Parece ter caído...")


func _mouse_saiu_quadro():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# LUZ MANUAL
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

		if som_luz_segurou:
			som_luz_segurou.stop()
		som_luz_segurou.play()

	else:

		_luz_soltou()


func _luz_soltou():

	if not luz_pressionada:
		return

	luz_pressionada = false

	if som_luz_segurou and som_luz_segurou.playing:
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

	if som_luz_soltou:
		som_luz_soltou.stop()
		som_luz_soltou.play()


# =========================================================
# CURSOR
# =========================================================

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
