
extends Node

signal inventario_atualizado

var itens: Array[String] = []


func adicionar_item(id: String):
	if id.is_empty():
		return

	if not itens.has(id):
		itens.append(id)
		inventario_atualizado.emit()


func tem_item(id: String) -> bool:
	return itens.has(id)


func remover_item(id: String):
	if itens.has(id):
		itens.erase(id)
		inventario_atualizado.emit()


func limpar():
	if not itens.is_empty():
		itens.clear()
		inventario_atualizado.emit()
