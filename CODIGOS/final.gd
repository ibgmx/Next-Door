extends Control

@onready var texto = $Texto
@onready var botao_menu = $BotaoInicio

var textos = [
	"Você finalmente encontrou a saída.",
	"Mas algumas respostas são difíceis de aceitar.",
	"Talvez você nunca tenha estado realmente sozinha.",
	"FIM"
]

var indice = 0
var espacamento = 90


func _ready():
	texto.hide()
	botao_menu.hide()

	botao_menu.mouse_entered.connect(_mouse_entrou_botao)
	botao_menu.mouse_exited.connect(_mouse_saiu_botao)

	_mostrar_texto()


func _mostrar_texto():
	if indice >= textos.size():
		botao_menu.show()
		return

	var novo_texto = texto.duplicate()

	novo_texto.text = textos[indice]

	# Centraliza o texto na tela
	novo_texto.position = Vector2(
		-texto.size.x / 2,
		(indice * espacamento) - (textos.size() * espacamento / 2)
	)

	novo_texto.size = texto.size
	novo_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	novo_texto.modulate.a = 0.0
	novo_texto.show()

	add_child(novo_texto)

	var entrada = create_tween()
	entrada.tween_property(novo_texto, "modulate:a", 1.0, 1.0)

	await entrada.finished
	await get_tree().create_timer(1.0).timeout

	indice += 1
	_mostrar_texto()


func _mouse_entrou_botao():
	Cursormanager.cursor_clique()


func _mouse_saiu_botao():
	Cursormanager.cursor_normal()


func _on_botao_inicio_pressed():
	Cursormanager.cursor_normal()

	Gamemanager.resetar_jogo()
	Gamemanager.mudar_cena("res://CENAS/início.tscn")
