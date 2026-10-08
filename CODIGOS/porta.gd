extends Area2D

@export_file("*.tscn") var destino: String
@export var chave_necessaria: String = ""

func _ready():
	input_pickable = true

	mouse_entered.connect(_mouse_entrou)
	mouse_exited.connect(_mouse_saiu)
	input_event.connect(_clicou)

func _clicou(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# A recepção é liberada pelo mouse da câmera da recepção.
			if name.to_lower().contains("recep"):
				if not Gamemanager.portas_abertas.get("recepcao", false):
					Cursormanager.cursor_normal()
					return

				Cursormanager.cursor_normal()
				Gamemanager.mudar_cena(destino)
				return

			# Portas que usam chave normalmente.
			if chave_necessaria != "":
				if not Inventario.tem_item(chave_necessaria):
					Cursormanager.cursor_normal()
					return

				Gamemanager.portas_abertas[chave_necessaria] = true

			Cursormanager.cursor_normal()
			Gamemanager.mudar_cena(destino)

func _mouse_entrou():
	Cursormanager.cursor_clique()

func _mouse_saiu():
	Cursormanager.cursor_normal()
