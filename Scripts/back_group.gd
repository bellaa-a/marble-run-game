extends Button


func _on_pressed() -> void:
	$Click.play()
	transition.fade_to_scene(get_tree().current_scene.last_scene_path)


func _on_mouse_entered() -> void:
	$NextBackPressed.visible = true


func _on_mouse_exited() -> void:
	$NextBackPressed.visible = false
