extends Node

var cena_atual: String = ""
var cena_anterior: String = ""

# Progresso
var escritorio_resolvido: bool = false
var recepcao_resolvida: bool = false
var cameras_resolvidas: bool = false

# Controla a piscada especial ao entrar no corredor vindo do quarto
var corredor_vindo_do_quarto: bool = false


func iniciar_jogo() -> void:
	cena_atual = "res://CENAS/quarto.tscn"
	cena_anterior = ""
	corredor_vindo_do_quarto = false
	get_tree().change_scene_to_file(cena_atual)


func mudar_cena(destino: String) -> void:
	cena_anterior = cena_atual

	if destino.ends_with("corredor.tscn") and cena_atual.ends_with("quarto.tscn"):
		corredor_vindo_do_quarto = true

	cena_atual = destino
	get_tree().change_scene_to_file(destino)


func voltar() -> void:
	if cena_anterior != "":
		var destino = cena_anterior

		cena_anterior = cena_atual
		cena_atual = destino

		get_tree().change_scene_to_file(destino)


func resetar_jogo() -> void:
	escritorio_resolvido = false
	recepcao_resolvida = false
	cameras_resolvidas = false

	# Limpa todos os itens
	if Inventario.has_method("limpar"):
		Inventario.limpar()

	cena_atual = ""
	cena_anterior = ""

	corredor_vindo_do_quarto = false
