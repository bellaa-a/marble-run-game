extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("ui_right"):
		_on_next_tutorial_pressed()

	elif event.is_action_pressed("ui_left"):
		_on_back_tutorial_pressed()

func _on_next_tutorial_pressed() -> void:
	$Click.play()
	await $Click.finished
	get_tree().change_scene_to_file(get_tree().current_scene.next_scene_path)

func _on_back_tutorial_pressed() -> void:
	$Click.play()
	await $Click.finished
	get_tree().change_scene_to_file(get_tree().current_scene.back_scene_path)
