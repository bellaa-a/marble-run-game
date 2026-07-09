extends Node

var player: AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = preload("res://Audio/music.mp3")
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = "Music"
	player.volume_db = -20
	player.play()

func restart_music():
	player.play(0.0)
