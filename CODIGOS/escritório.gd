extends Node2D


# =========================================================
# GAVETAS
# =========================================================

@onready var gaveta_mesa = $Gavetamesa
@onready var gaveta = $Gaveta

@onready var gaveta_mesa_canvas = $GavetaMesa
@onready var gavetinha_canvas = $Gavetinha
@onready var tela_senha = $TelaSenha

@onready var botao_gaveta_mesa = $GavetaMesa/BotaoFechar
@onready var botao_gavetinha = $Gavetinha/BotaoFechar


# =========================================================
# SENHA
# =========================================================

@onready var campo = $TelaSenha/CampoTexto
@onready var botao_senha = $TelaSenha/BotaoConfirmar
@onready var botao_fechar_senha = $TelaSenha/BotaoFechar
@onready var mensagem = $TelaSenha/Mensagem


# =========================================================
# SOM / CÂMERA
# =========================================================

@onready var som_porta = $SomPorta
@onready var som_porta_entrando = $SomPortaEntrando
@onready var camera = $Camera2D

# SONS
@onready var som_segurou = $Luz/Segurou
@onready var som_soltou = $Luz/Soltou
@onready var som_telefone = $Telefone/Telefone

@onready var som_abrindo_gaveta_mesa = $GavetaMesa/Abrindo
@onready var som_fechar_gaveta_mesa = $GavetaMesa/Fechando
@onready var som_abrindo_gavetinha = $Gavetinha/Abrindo
@onready var som_fechar_gavetinha = $Gavetinha/Fechando


# =========================================================
# ITENS
# =========================================================

# Chave3 está dentro da GavetaMesa
@onready var chave3 = $GavetaMesa/Chave3

# Código3 está dentro da Gavetinha
@onready var codigo3 = $Gavetinha/Código3

@onready var receita = $Receita
@onready var dica = $Dica

# NOVAS ÁREAS
@onready var papel1 = $Papel1
@onready var papel2 = $Papel2
@onready var papel3 = $Papel3
@onready var carimbo = $Carimbo
@onready var caixa = $Caixa
@onready var telefone = $Telefone
@onready var cloza = $Cloza


# =========================================================
# PERSONAGEM
# =========================================================

@onready var taylor = $Taylor


# =========================================================
# LUZ
# =========================================================

@onready var luz = $Luz
@onready var preto = $Preto

var luz_pressionada := false
var luz_piscando := false
var luz_aguardando_soltou := false


# =========================================================
# DESCRIÇÃO
# =========================================================

@onready var descricao = $InterfaceDescricao/Descricao

var descricao_tween: Tween
var coleta_tween

# Impede que o mouse_exited apague a mensagem
# enquanto o jogador acabou de pegar um item.
var descricao_coleta_ativa := false


# =========================================================
# OUTROS
# =========================================================

var ultimo_clique_fora := 0


# =========================================================
# READY
# =========================================================

func _ready():

	# Cursor dedinho no botão de sair da sala.
	_configurar_cursor_botao_sair()

	# =====================================================
	# CANVAS
	# =====================================================

	gaveta_mesa_canvas.hide()
	gavetinha_canvas.hide()
	tela_senha.hide()
	mensagem.hide()


	# =====================================================
	# GAVETAS
	# =====================================================

	gaveta_mesa.input_pickable = true
	gaveta.input_pickable = true

	gaveta_mesa.input_event.connect(_clicou_gaveta_mesa)
	gaveta.input_event.connect(_clicou_gaveta)

	gaveta_mesa.mouse_entered.connect(_mouse_entrou_gaveta_mesa)
	gaveta_mesa.mouse_exited.connect(_mouse_saiu_gaveta_mesa)

	gaveta.mouse_entered.connect(_mouse_entrou_gaveta)
	gaveta.mouse_exited.connect(_mouse_saiu_gaveta)


	# =====================================================
	# CHAVE3
	# =====================================================

	chave3.input_pickable = true

	chave3.input_event.connect(_clicou_chave3)

	chave3.mouse_entered.connect(_mouse_entrou_chave3)
	chave3.mouse_exited.connect(_mouse_saiu_chave3)

	if Inventario.tem_item("chave3"):

		chave3.hide()
		chave3.input_pickable = false


	# =====================================================
	# CÓDIGO3
	# =====================================================

	codigo3.input_pickable = true

	codigo3.input_event.connect(_clicou_codigo3)

	codigo3.mouse_entered.connect(_mouse_entrou_codigo3)
	codigo3.mouse_exited.connect(_mouse_saiu_codigo3)

	if Inventario.tem_item("codigo3"):

		codigo3.hide()
		codigo3.input_pickable = false


	# =====================================================
	# RECEITA
	# =====================================================

	receita.input_pickable = true

	receita.input_event.connect(_clicou_receita)

	receita.mouse_entered.connect(_mouse_entrou_receita)
	receita.mouse_exited.connect(_mouse_saiu_receita)

	if Inventario.tem_item("receita"):

		receita.hide()
		receita.input_pickable = false


	# =====================================================
	# DICA
	# =====================================================

	dica.input_pickable = true

	dica.input_event.connect(_clicou_dica)

	dica.mouse_entered.connect(_mouse_entrou_dica)
	dica.mouse_exited.connect(_mouse_saiu_dica)

	if Inventario.tem_item("dica"):

		dica.hide()
		dica.input_pickable = false


	# =====================================================
	# NOVAS ÁREAS
	# =====================================================

	_configurar_area(papel1, _clicou_papel1, _mouse_entrou_papel1, _mouse_saiu_papel1)
	_configurar_area(papel2, _clicou_papel2, _mouse_entrou_papel2, _mouse_saiu_papel2)
	_configurar_area(papel3, _clicou_papel3, _mouse_entrou_papel3, _mouse_saiu_papel3)
	_configurar_area(carimbo, _clicou_carimbo, _mouse_entrou_carimbo, _mouse_saiu_carimbo)
	_configurar_area(caixa, _clicou_caixa, _mouse_entrou_caixa, _mouse_saiu_caixa)
	_configurar_area(telefone, _clicou_telefone, _mouse_entrou_telefone, _mouse_saiu_telefone)
	_configurar_area(cloza, _clicou_cloza, _mouse_entrou_cloza, _mouse_saiu_cloza)


	# =====================================================
	# TAYLOR
	# =====================================================

	taylor.input_pickable = true

	taylor.input_event.connect(_clicou_taylor)

	taylor.mouse_entered.connect(_mouse_entrou_taylor)
	taylor.mouse_exited.connect(_mouse_saiu_taylor)


	# =====================================================
	# BOTÕES DAS GAVETAS
	# =====================================================

	botao_gaveta_mesa.pressed.connect(_fechar_gaveta_mesa)
	botao_gavetinha.pressed.connect(_fechar_gavetinha)

	botao_gaveta_mesa.mouse_entered.connect(_mouse_entrou)
	botao_gaveta_mesa.mouse_exited.connect(_mouse_saiu)

	botao_gavetinha.mouse_entered.connect(_mouse_entrou)
	botao_gavetinha.mouse_exited.connect(_mouse_saiu)


	# =====================================================
	# SENHA
	# =====================================================

	botao_senha.pressed.connect(_verificar_senha)
	botao_fechar_senha.pressed.connect(_fechar_tela_senha)

	botao_senha.mouse_entered.connect(_mouse_entrou)
	botao_senha.mouse_exited.connect(_mouse_saiu)
	botao_fechar_senha.mouse_entered.connect(_mouse_entrou)
	botao_fechar_senha.mouse_exited.connect(_mouse_saiu)

	campo.text_submitted.connect(_senha_por_enter)


	# =====================================================
	# LUZ
	# =====================================================

	preto.hide()

	luz.input_pickable = true

	luz.input_event.connect(_clicou_luz)

	luz.mouse_entered.connect(_mouse_entrou_luz)
	luz.mouse_exited.connect(_mouse_saiu_luz)

	if som_segurou:
		som_segurou.finished.connect(_segurou_terminou)

	# Começa o sistema de piscadas automáticas.
	call_deferred("_iniciar_piscadas_luz")


	# =====================================================
	# ENTRADA DO ESCRITÓRIO
	# =====================================================

	if not Gamemanager.escritorio_entrada_feita:

		Gamemanager.escritorio_entrada_feita = true

		# Primeira entrada: somente SomPorta.
		# Depois que ele terminar, a câmera treme.
		if som_porta:
			som_porta.stop()
			som_porta.play()

			await som_porta.finished

		_balancar_camera()

	else:

		# Entradas seguintes: SomPorta é totalmente ignorado.
		# Apenas SomPortaEntrando, sem tremida.
		if som_porta_entrando:
			som_porta_entrando.stop()
			som_porta_entrando.play()


# =========================================================
# CURSOR DO BOTÃO DE SAIR
# =========================================================

func _configurar_cursor_botao_sair():

	var botao_sair = _encontrar_botao_sair(self)

	if botao_sair == null:
		return

	if not botao_sair.mouse_entered.is_connected(_mouse_entrou):
		botao_sair.mouse_entered.connect(_mouse_entrou)

	if not botao_sair.mouse_exited.is_connected(_mouse_saiu):
		botao_sair.mouse_exited.connect(_mouse_saiu)


func _encontrar_botao_sair(no: Node) -> BaseButton:

	for filho in no.get_children():

		if filho is BaseButton:
			var nome = filho.name.to_lower()

			if nome.contains("sair"):
				return filho

		var encontrado = _encontrar_botao_sair(filho)

		if encontrado != null:
			return encontrado

	return null


# =========================================================
# INPUT
# =========================================================

func _input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if luz_pressionada:
				_luz_soltou()

	if not tela_senha.visible:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			if botao_senha.get_global_rect().has_point(event.position):
				return

			if botao_fechar_senha.get_global_rect().has_point(event.position):
				return

			var agora = Time.get_ticks_msec()

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
# GAVETA DA MESA
# =========================================================

func _clicou_gaveta_mesa(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			gaveta_mesa_canvas.show()
			gavetinha_canvas.hide()
			tela_senha.hide()

			_bloquear_cenario()

			if som_abrindo_gaveta_mesa:
				som_abrindo_gaveta_mesa.play()

			Cursormanager.cursor_normal()


func _mouse_entrou_gaveta_mesa():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma gaveta.")


func _mouse_saiu_gaveta_mesa():

	Cursormanager.cursor_normal()

	esconder_descricao()


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

			if som_abrindo_gavetinha:
				som_abrindo_gavetinha.play()

			Cursormanager.cursor_normal()


func _mouse_entrou_gaveta():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma gavetinha.")


func _mouse_saiu_gaveta():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# CHAVE3
# =========================================================

func _clicou_chave3(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("chave3")

			chave3.hide()
			chave3.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou uma chave.")

			_fade_descricao_item()


func _mouse_entrou_chave3():

	Cursormanager.cursor_clique()

	mostrar_descricao("Uma chave, o que ela abre?")


func _mouse_saiu_chave3():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# CÓDIGO3
# =========================================================

func _clicou_codigo3(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("codigo3")

			codigo3.hide()
			codigo3.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou um código.")

			_fade_descricao_item()


func _mouse_entrou_codigo3():

	Cursormanager.cursor_clique()

	mostrar_descricao("Parece um código.")


func _mouse_saiu_codigo3():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# RECEITA
# =========================================================

func _clicou_receita(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("receita")

			receita.hide()
			receita.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou uma receita.")

			_fade_descricao_item()


func _mouse_entrou_receita():

	Cursormanager.cursor_clique()

	mostrar_descricao("Que texto confuso...")


func _mouse_saiu_receita():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# DICA
# =========================================================

func _clicou_dica(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Inventario.adicionar_item("dica")

			dica.hide()
			dica.input_pickable = false

			Cursormanager.cursor_normal()

			mostrar_descricao("Você pegou uma dica.")

			_fade_descricao_item()


func _mouse_entrou_dica():

	Cursormanager.cursor_clique()

	mostrar_descricao("Que letra estranha.")


func _mouse_saiu_dica():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# NOVAS ÁREAS
# =========================================================

func _configurar_area(area: Area2D, clique: Callable, entrou: Callable, saiu: Callable):

	area.input_pickable = true
	area.input_event.connect(clique)
	area.mouse_entered.connect(entrou)
	area.mouse_exited.connect(saiu)


func _clicou_papel1(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Cursormanager.cursor_clique()
		mostrar_descricao("Parece irrelevante.")


func _mouse_entrou_papel1():
	Cursormanager.cursor_clique()
	mostrar_descricao("Quê?")


func _mouse_saiu_papel1():
	Cursormanager.cursor_normal()
	esconder_descricao()


func _clicou_papel2(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Cursormanager.cursor_clique()
		mostrar_descricao("Não parece útil.")


func _mouse_entrou_papel2():
	Cursormanager.cursor_clique()
	mostrar_descricao("Mais um papel.")


func _mouse_saiu_papel2():
	Cursormanager.cursor_normal()
	esconder_descricao()


func _clicou_papel3(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Cursormanager.cursor_clique()
		mostrar_descricao("Calma... deixa, devo estar vendo errado.")


func _mouse_entrou_papel3():
	Cursormanager.cursor_clique()
	mostrar_descricao("Algumas anotações.")


func _mouse_saiu_papel3():
	Cursormanager.cursor_normal()
	esconder_descricao()


func _clicou_carimbo(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Cursormanager.cursor_clique()
		mostrar_descricao("A tinta parece fresca.")


func _mouse_entrou_carimbo():
	Cursormanager.cursor_clique()
	mostrar_descricao("Um carimbo.")


func _mouse_saiu_carimbo():
	Cursormanager.cursor_normal()
	esconder_descricao()


func _clicou_caixa(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Cursormanager.cursor_clique()
		mostrar_descricao("Tá fechada.")


func _mouse_entrou_caixa():
	Cursormanager.cursor_clique()
	mostrar_descricao("Uma caixa.")


func _mouse_saiu_caixa():
	Cursormanager.cursor_normal()
	esconder_descricao()


func _clicou_telefone(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if som_telefone:
			som_telefone.play()
		Cursormanager.cursor_clique()
		mostrar_descricao("Ahh! que alto!")


func _mouse_entrou_telefone():
	Cursormanager.cursor_clique()
	mostrar_descricao("Um telefone.")


func _mouse_saiu_telefone():
	Cursormanager.cursor_normal()
	esconder_descricao()


func _clicou_cloza(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Cursormanager.cursor_clique()
		mostrar_descricao("Acho que já vi isso...")


func _mouse_entrou_cloza():
	Cursormanager.cursor_clique()
	mostrar_descricao("Mais remédios.")


func _mouse_saiu_cloza():
	Cursormanager.cursor_normal()
	esconder_descricao()


# =========================================================
# TAYLOR
# =========================================================

func _clicou_taylor(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			Cursormanager.cursor_normal()

			mostrar_descricao("Estranho.")

			_fade_descricao()


func _mouse_entrou_taylor():

	Cursormanager.cursor_clique()

	mostrar_descricao("Parece familiar...")


func _mouse_saiu_taylor():

	Cursormanager.cursor_normal()

	esconder_descricao()


# =========================================================
# FECHAR GAVETA DA MESA
# =========================================================

func _fechar_gaveta_mesa():

	gaveta_mesa_canvas.hide()

	_desbloquear_cenario()

	if som_fechar_gaveta_mesa:
		som_fechar_gaveta_mesa.play()

	Cursormanager.cursor_normal()


# =========================================================
# FECHAR GAVETINHA
# =========================================================

func _fechar_gavetinha():

	gavetinha_canvas.hide()

	_desbloquear_cenario()

	if som_fechar_gavetinha:
		som_fechar_gavetinha.play()

	Cursormanager.cursor_normal()


# =========================================================
# BLOQUEAR CENÁRIO
# =========================================================

func _bloquear_cenario():

	# Somente objetos do cenário principal são bloqueados.

	gaveta_mesa.input_pickable = false
	gaveta.input_pickable = false

	receita.input_pickable = false
	dica.input_pickable = false
	papel1.input_pickable = false
	papel2.input_pickable = false
	papel3.input_pickable = false
	carimbo.input_pickable = false
	caixa.input_pickable = false
	telefone.input_pickable = false
	cloza.input_pickable = false

	taylor.input_pickable = false
	luz.input_pickable = false

	# NÃO bloquear:
	#
	# chave3
	# codigo3
	#
	# Eles estão dentro das gavetas abertas e precisam
	# continuar clicáveis.


# =========================================================
# DESBLOQUEAR CENÁRIO
# =========================================================

func _desbloquear_cenario():

	gaveta_mesa.input_pickable = true
	gaveta.input_pickable = true

	if not Inventario.tem_item("receita"):
		receita.input_pickable = true

	if not Inventario.tem_item("dica"):
		dica.input_pickable = true

	papel1.input_pickable = true
	papel2.input_pickable = true
	papel3.input_pickable = true
	carimbo.input_pickable = true
	caixa.input_pickable = true
	telefone.input_pickable = true
	cloza.input_pickable = true

	taylor.input_pickable = true
	luz.input_pickable = true

	# Os itens das gavetas só precisam estar habilitados
	# quando suas respectivas gavetas estiverem abertas.

	if gaveta_mesa_canvas.visible:

		if not Inventario.tem_item("chave3"):
			chave3.input_pickable = true

	if gavetinha_canvas.visible:

		if not Inventario.tem_item("codigo3"):
			codigo3.input_pickable = true


# =========================================================
# SETA PARA SAIR
# =========================================================

func tentar_sair():

	if Gamemanager.escritorio_resolvido:

		Cursormanager.cursor_normal()

		Gamemanager.mudar_cena(
			"res://CENAS/corredor.tscn"
		)

		return


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

		Gamemanager.mudar_cena(
			"res://CENAS/corredor.tscn"
		)

	else:

		mensagem.text = "Código incorreto."
		mensagem.show()

		campo.clear()
		campo.grab_focus()


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


# =========================================================
# CURSOR DA LUZ
# =========================================================

func _mouse_entrou_luz():
	Cursormanager.cursor_clique()


func _mouse_saiu_luz():
	Cursormanager.cursor_normal()


# =========================================================
# PISCADAS AUTOMÁTICAS DA LUZ
# =========================================================

func _iniciar_piscadas_luz():

	while true:

		# Espera bastante entre cada acontecimento.
		var espera = randf_range(15.0, 30.0)

		await get_tree().create_timer(espera).timeout

		if not luz_pressionada:

			await _piscar_luz_automaticamente()


func _piscar_luz_automaticamente():

	if luz_piscando:
		return

	if luz_pressionada:
		return

	luz_piscando = true

	var quantidade = randi_range(2, 5)

	for i in range(quantidade):

		if luz_pressionada:
			break

		preto.show()

		var tempo_escuro = randf_range(0.04, 0.16)

		await get_tree().create_timer(tempo_escuro).timeout

		if luz_pressionada:
			break

		preto.hide()

		var intervalo = randf_range(0.08, 0.45)

		await get_tree().create_timer(intervalo).timeout


	if not luz_pressionada:

		preto.hide()

	luz_piscando = false


# =========================================================
# CURSOR GENÉRICO
# =========================================================

func _mouse_entrou():

	Cursormanager.cursor_clique()


func _mouse_saiu():

	Cursormanager.cursor_normal()


# =========================================================
# DESCRIÇÃO
# =========================================================

func mostrar_descricao(texto: String):

	if descricao == null:
		return

	# Se estamos mostrando a mensagem de coleta,
	# o hover não deve substituí-la.
	if descricao_coleta_ativa:
		return

	if descricao_tween:
		descricao_tween.kill()

	descricao.text = texto
	descricao.show()
	descricao.modulate.a = 1.0


func esconder_descricao():

	if descricao == null:
		return

	# Muito importante:
	# o mouse_exited de um item coletado não pode
	# apagar a mensagem "Você pegou...".
	if descricao_coleta_ativa:
		return

	if descricao_tween:
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
# FADE DE DESCRIÇÃO NORMAL
# =========================================================

func _fade_descricao():

	if descricao_tween:
		descricao_tween.kill()

	descricao_tween = create_tween()

	descricao_tween.tween_interval(2.0)

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
# FADE AO PEGAR ITEM
# =========================================================

func _fade_descricao_item():

	descricao_coleta_ativa = true

	if descricao_tween:
		descricao_tween.kill()

	if coleta_tween:
		coleta_tween.kill()

	coleta_tween = create_tween()

	# Tempo para ler a mensagem.
	coleta_tween.tween_interval(2.0)

	# Fade igual ao padrão das outras descrições.
	coleta_tween.tween_property(
		descricao,
		"modulate:a",
		0.0,
		0.5
	)

	coleta_tween.tween_callback(_finalizar_fade_coleta)


func _finalizar_fade_coleta():

	descricao_coleta_ativa = false
	descricao.hide()
