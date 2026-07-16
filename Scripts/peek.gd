extends Control

@onready var eyes = $Eyes
@onready var player1 = $Eyes/Player1
@onready var player2 = $Eyes/Player2
@onready var username = $Eyes/Username

func _ready() -> void:
	#var pipe_screen_pos = get_viewport().get_canvas_transform() * Multiplayer.pipe_position
	#eyes.position = pipe_screen_pos - Vector2(25, 0)
	username.text = Multiplayer.get_opponent_name()
	if Multiplayer.opponent_is_host():
		player1.visible = true
		player2.visible = false
	else:
		player2.visible = true
		player1.visible = false
