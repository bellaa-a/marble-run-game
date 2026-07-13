extends Node

var transition_scene = preload("res://Scenes/transition.tscn")
var instance

func fade_to_scene(path, restart_music := false):
	if instance == null:
		instance = transition_scene.instantiate()
		get_tree().root.add_child(instance)

	await instance.play_transition(path, restart_music)

func switch_to_win_lose(path: String, data := {}):
	var new_scene = load(path).instantiate()

	for key in data:
		new_scene.set(key, data[key])

	var old_scene = get_tree().current_scene
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	await get_tree().process_frame
	old_scene.queue_free()
