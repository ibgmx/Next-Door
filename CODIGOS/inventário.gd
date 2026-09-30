extends Node

var itens: Array[String] = []


func adicionar_item(id: String):
	if not itens.has(id):
		itens.append(id)


func tem_item(id: String) -> bool:
	return itens.has(id)


func remover_item(id: String):
	itens.erase(id)


func limpar():
	itens.clear()
