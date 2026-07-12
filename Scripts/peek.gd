extends Control


@onready var player1 = $Player1
@onready var player2 = $Player2

func _ready() -> void:
	player1.global_position = Multiplayer.pipe_position + Vector2(10, 0)
	player2.global_position = Multiplayer.pipe_position + Vector2(10, 0)
	$Username.text = Multiplayer.get_opponent_name()
	if Multiplayer.opponent_is_host():
		player1.visible = true
	else:
		player2.visible = true
