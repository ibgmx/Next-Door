extends Node

const CURSOR_NORMAL = preload("res://ARTES/cursor/cursor.png")
const CURSOR_CLIQUE = preload("res://ARTES/CURSOR/cursor dedinho.png")


func _ready():
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)


func cursor_clique():
	Input.set_custom_mouse_cursor(CURSOR_CLIQUE)


func cursor_normal():
	Input.set_custom_mouse_cursor(CURSOR_NORMAL)
