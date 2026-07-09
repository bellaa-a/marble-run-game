extends TextureButton


func _on_pressed() -> void:
	transition.fade_to_scene("res://Scenes/tutorial1a.tscn")
