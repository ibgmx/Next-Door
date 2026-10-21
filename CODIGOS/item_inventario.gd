
extends TextureButton
class_name ItemInventario

@export var id_item: String = ""
@export var nome_item: String = ""
@export var imagem_documento: Texture2D

@onready var botao_imagem: TextureButton = get_node_or_null("Imagem")


func _ready():
	tooltip_text = nome_item
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	if botao_imagem != null:
		botao_imagem.mouse_filter = Control.MOUSE_FILTER_STOP
		botao_imagem.tooltip_text = nome_item

		if not botao_imagem.pressed.is_connected(_ao_clicar):
			botao_imagem.pressed.connect(_ao_clicar)

		if not botao_imagem.mouse_entered.is_connected(_mouse_entrou):
			botao_imagem.mouse_entered.connect(_mouse_entrou)

		if not botao_imagem.mouse_exited.is_connected(_mouse_saiu):
			botao_imagem.mouse_exited.connect(_mouse_saiu)
	else:
		print("ERRO: não encontrei o botão filho Imagem em ", name)

	if not Inventario.inventario_atualizado.is_connected(
		_atualizar_visibilidade
	):
		Inventario.inventario_atualizado.connect(
			_atualizar_visibilidade
		)

	_atualizar_visibilidade()


func _exit_tree():
	if Inventario.inventario_atualizado.is_connected(
		_atualizar_visibilidade
	):
		Inventario.inventario_atualizado.disconnect(
			_atualizar_visibilidade
		)


func _atualizar_visibilidade():
	var possui_item: bool = (
		not id_item.is_empty()
		and Inventario.tem_item(id_item)
	)

	if botao_imagem != null:
		botao_imagem.visible = possui_item


func _mouse_entrou():
	Cursormanager.cursor_clique()


func _mouse_saiu():
	Cursormanager.cursor_normal()


func _ao_clicar():
	print("Clique recebido no item: ", id_item)

	if imagem_documento == null:
		print("Este item não tem imagem de documento configurada.")
		return

	var atual: Node = self

	while atual != null and not atual is CanvasLayer:
		atual = atual.get_parent()

	if atual != null and atual.has_method("_alternar_documento"):
		atual._alternar_documento(self)
