extends Node

var transition_scene = preload("res://Scenes/transition.tscn")
var instance

func fade_to_scene(path, restart_music := false):
	if instance == null:
		instance = transition_scene.instantiate()
		get_tree().root.add_child(instance)

	await instance.play_transition(path, restart_music)
