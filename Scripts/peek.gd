extends Control

@onready var eyes = $Eyes
@onready var player1 = $Eyes/Player1
@onready var player2 = $Eyes/Player2

func _ready() -> void:
	eyes.global_position = Multiplayer.pipe_position + Vector2(10, 0)
	$Username.text = Multiplayer.get_opponent_name()
	if Multiplayer.opponent_is_host():
		player1.visible = true
		player2.visible = false
	else:
		player2.visible = true
		player1.visible = false
