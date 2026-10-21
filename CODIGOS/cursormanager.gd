extends Node

const CURSOR_NORMAL = preload("res://ARTES/cursor/cursor.png")
const CURSOR_CLIQUE = preload("res://ARTES/CURSOR/cursor dedinho.png")

var cursor_normal_reduzido: ImageTexture
var cursor_clique_reduzido: ImageTexture


func _ready():
	cursor_normal_reduzido = _reduzir_cursor(CURSOR_NORMAL)
	cursor_clique_reduzido = _reduzir_cursor(CURSOR_CLIQUE)

	cursor_normal()


func _reduzir_cursor(textura: Texture2D) -> ImageTexture:
	var imagem: Image = textura.get_image()

	var largura: int = maxi(1, int(imagem.get_width() / 6))
	var altura: int = maxi(1, int(imagem.get_height() / 5.5))

	imagem.resize(largura, altura, Image.INTERPOLATE_LANCZOS)

	return ImageTexture.create_from_image(imagem)


func cursor_clique():
	Input.set_custom_mouse_cursor(cursor_clique_reduzido)


func cursor_normal():
	Input.set_custom_mouse_cursor(cursor_normal_reduzido)
