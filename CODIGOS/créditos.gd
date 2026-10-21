extends Control

@onready var botao_voltar = $"Voltar"
@onready var texto: RichTextLabel = $"Texto"

func _ready():
	botao_voltar.mouse_entered.connect(cursor_clique)
	botao_voltar.mouse_exited.connect(cursor_normal)

	texto.bbcode_enabled = true
	texto.text = """[url=sofia]Sofia Coelho[/url]: Arte e Design.
[url=eloah]Eloah Tenório[/url]: Design de Áudio.
[url=myrella]Myrella Moura[/url]: Roteirista.
[url=thais]Thais Veneziano[/url]: Roteirista.
Gustavo Meletti: Apoio moral.
Livia Andre: Desenvolvedora inicial.
[url=bryan]Bryan Machado[/url]: Game e Level Designer."""

	# meta_clicked já está conectado pelo editor (_on_texto_meta_clicked).
	texto.meta_hover_started.connect(_on_texto_meta_hover_started)
	texto.meta_hover_ended.connect(_on_texto_meta_hover_ended)


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://CENAS/início.tscn")


func cursor_clique():
	Cursormanager.cursor_clique()


func cursor_normal():
	Cursormanager.cursor_normal()


func _on_texto_meta_clicked(meta: Variant) -> void:
	match str(meta):
		"eloah":
			OS.shell_open("https://eloah-tenorio.netlify.app")  
		"bryan":
			OS.shell_open("https://bryan-machado.netlify.app")  
		"sofia":
			OS.shell_open("https://www.instagram.com/coeelhaart")  
		"myrella":
			OS.shell_open("https://www.instagram.com/m.fialho__")  
		"thais":
			OS.shell_open("https://www.instagram.com/wzthaiss")  
		


func _on_texto_meta_hover_started(_meta: Variant) -> void:
	cursor_clique()


func _on_texto_meta_hover_ended(_meta: Variant) -> void:
	cursor_normal()
