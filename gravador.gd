extends TextureButton

var som = null
var terminou_sozinho := false


func _ready():
	som = _achar_conversa()

	if som == null:
		push_warning("Nó 'Conversa' não encontrado a partir de " + str(get_path()))
	else:
		som.finished.connect(_ao_terminar)

	pressed.connect(_ao_clicar)


func _achar_conversa():
	var no: Node = self

	while no != null:
		var achado = no.find_child("Conversa", true, false)

		if achado != null:
			return achado

		no = no.get_parent()

	return null


func _ao_terminar():
	# O áudio acabou sem ninguém clicar.
	terminou_sozinho = true


func _ao_clicar():
	if som == null:
		return

	if som.playing:
		# Clicou durante o som: para.
		som.stop()
		terminou_sozinho = false

	elif terminou_sozinho:
		# Primeiro clique depois do fim natural: não toca.
		# (é o clique que fecha o item)
		terminou_sozinho = false

	else:
		som.play()
