extends Node

@onready var musica = $Musica

func _ready():
	musica.finished.connect(_musica_terminou)
	musica.play()

func _musica_terminou():
	musica.play()
