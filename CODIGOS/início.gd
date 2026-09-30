extends Control

@onready var botao_creditos = $"Créditos"
@onready var botao_iniciar = $"Iniciar"
@onready var faz = $Luz


func _ready():
	botao_creditos.mouse_entered.connect(cursor_clique)
	botao_creditos.mouse_exited.connect(cursor_normal)

	botao_iniciar.mouse_entered.connect(cursor_clique)
	botao_iniciar.mouse_exited.connect(cursor_normal)

	_alternar_luz()


func _alternar_luz():
	while true:
		faz.visible = true
		await get_tree().create_timer(2.0).timeout

		faz.visible = false
		await get_tree().create_timer(2.0).timeout


func cursor_clique():
	Cursormanager.cursor_clique()


func cursor_normal():
	Cursormanager.cursor_normal()


func _on_créditos_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/créditos.tscn")


func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/abertura.tscn")
