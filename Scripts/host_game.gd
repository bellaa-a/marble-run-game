extends Node2D


var frames = [0, 1, 2, 3, 4, 5, 5, 5]
var frame = 0

func _ready():
	$GameID.text = "Your game ID: %s" % Multiplayer.lobby_code
	Multiplayer.lobby_ready.connect(_on_lobby_ready)


func _on_timer_timeout() -> void:
	frame = (frame + 1) % frames.size()
	$WaitingLabel.text = "Waiting for your opponent" + ".".repeat(frames[frame])


func _on_lobby_ready():

	print("Opponent connected!")

	transition.fade_to_scene("res://Scenes/connected.tscn")
