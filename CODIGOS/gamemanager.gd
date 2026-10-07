extends Node


var cena_atual: String = ""
var cena_anterior: String = ""


# =========================
# PROGRESSO
# =========================

var escritorio_resolvido: bool = false
var recepcao_resolvida: bool = false
var cameras_resolvidas: bool = false


# Controla se o efeito de entrada das salas já aconteceu
var escritorio_entrada_feita: bool = false
var cameras_entrada_feita: bool = false


# =========================
# FADE DO QUARTO
# =========================

# Quando true, o quarto entra com fade de preto.
# É usado apenas ao iniciar/reiniciar o jogo.
var quarto_com_fade: bool = false


# =========================
# EFEITOS DO CORREDOR
# =========================

# Indica de qual lugar o jogador acabou de voltar
var corredor_vindo_do_quarto: bool = false
var corredor_vindo_do_escritorio: bool = false
var corredor_vindo_das_cameras: bool = false


# Impede que o efeito especial se repita
var efeito_corredor_quarto_feito: bool = false
var efeito_corredor_escritorio_feito: bool = false
var efeito_corredor_cameras_feito: bool = false


# =========================
# PORTAS
# =========================

# Guarda quais portas já foram abertas
var portas_abertas: Dictionary = {}


# =========================
# INICIAR JOGO
# =========================

func iniciar_jogo() -> void:

	cena_atual = "res://CENAS/quarto.tscn"
	cena_anterior = ""

	corredor_vindo_do_quarto = false
	corredor_vindo_do_escritorio = false
	corredor_vindo_das_cameras = false

	# Faz o quarto entrar com fade
	quarto_com_fade = true

	get_tree().change_scene_to_file(cena_atual)


# =========================
# REGISTRAR ENTRADA NO CORREDOR
# =========================

func _registrar_entrada_corredor(destino: String, origem: String) -> void:

	if not destino.ends_with("corredor.tscn"):
		return


	# =========================
	# QUARTO
	# =========================

	if origem.ends_with("quarto.tscn"):

		if not efeito_corredor_quarto_feito:

			corredor_vindo_do_quarto = true
			efeito_corredor_quarto_feito = true


	# =========================
	# ESCRITÓRIO
	# =========================

	elif origem.ends_with("escritório.tscn"):

		if not efeito_corredor_escritorio_feito:

			corredor_vindo_do_escritorio = true
			efeito_corredor_escritorio_feito = true


	# =========================
	# CÂMERAS
	# =========================

	elif origem.ends_with("câmeras.tscn"):

		if not efeito_corredor_cameras_feito:

			corredor_vindo_das_cameras = true
			efeito_corredor_cameras_feito = true


# =========================
# MUDAR CENA
# =========================

func mudar_cena(destino: String) -> void:

	var origem = cena_atual

	cena_anterior = cena_atual

	_registrar_entrada_corredor(destino, origem)

	cena_atual = destino

	get_tree().change_scene_to_file(destino)


# =========================
# VOLTAR
# =========================

func voltar() -> void:

	if cena_anterior != "":

		var destino = cena_anterior
		var origem = cena_atual

		# Registra também quando o jogador
		# volta usando a seta de voltar.
		_registrar_entrada_corredor(destino, origem)

		cena_anterior = cena_atual
		cena_atual = destino

		get_tree().change_scene_to_file(destino)


# =========================
# RESETAR JOGO
# =========================

func resetar_jogo() -> void:

	# =========================
	# PROGRESSO
	# =========================

	escritorio_resolvido = false
	recepcao_resolvida = false
	cameras_resolvidas = false


	# =========================
	# EFEITOS DE ENTRADA
	# =========================

	escritorio_entrada_feita = false
	cameras_entrada_feita = false


	# =========================
	# FADE DO QUARTO
	# =========================

	# O próximo quarto carregado deverá
	# começar preto e fazer fade para a cena.
	quarto_com_fade = true


	# =========================
	# EFEITOS DO CORREDOR
	# =========================

	corredor_vindo_do_quarto = false
	corredor_vindo_do_escritorio = false
	corredor_vindo_das_cameras = false

	efeito_corredor_quarto_feito = false
	efeito_corredor_escritorio_feito = false
	efeito_corredor_cameras_feito = false


	# =========================
	# PORTAS
	# =========================

	portas_abertas.clear()


	# =========================
	# INVENTÁRIO
	# =========================

	if Inventario.has_method("limpar"):
		Inventario.limpar()


	# =========================
	# CENAS
	# =========================

	cena_atual = ""
	cena_anterior = ""
