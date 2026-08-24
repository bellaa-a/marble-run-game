extends Node2D

@onready var eyes = $Eyes
@onready var player1 = $Eyes/Player1
@onready var player2 = $Eyes/Player2
@onready var username = $Eyes/Username

func _ready() -> void:
	username.text = Steam.getPersonaName()
	if Multiplayer.opponent_is_host():
		player1.visible = false
		player2.visible = true
	else:
		player2.visible = false
		player1.visible = true
