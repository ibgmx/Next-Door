extends Control

@onready var texto = $Texto

var textos = [
	"Algumas coisas não são o que parecem.",
	"Às vezes, a realidade começa a se desfazer.",
	"Você só precisa encontrar uma saída."
]

var indice = 0


func _ready():
	texto.modulate.a = 0.0
	_mostrar_texto()


func _mostrar_texto():
	if indice >= textos.size():
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://CENAS/quarto.tscn")
		return

	texto.text = textos[indice]

	var entrada = create_tween()
	entrada.tween_property(texto, "modulate:a", 1.0, 1.0)

	await entrada.finished
	await get_tree().create_timer(2.0).timeout

	var saida = create_tween()
	saida.tween_property(texto, "modulate:a", 0.0, 1.0)

	await saida.finished

	indice += 1
	_mostrar_texto()
