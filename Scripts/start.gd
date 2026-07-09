extends Node2D


func _ready() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, false)

func _on_single_pressed() -> void:
	$Boarder/Click.play()
	if GameState.didTutorial == false:
		transition.fade_to_scene("res://Scenes/intro_scene1.tscn")
	else:
		transition.fade_to_scene(GameState.get_current_screen())


func _on_double_pressed() -> void:
	$Boarder/Click.play()
	transition.fade_to_scene("res://Scenes/rooms.tscn")
