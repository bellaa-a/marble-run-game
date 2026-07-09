extends Node2D

var settings_scene = preload("res://Scenes/settings.tscn")


func _on_settings_pressed() -> void:
	$Click.play()
	await $Click.finished
	var settings = settings_scene.instantiate()
	add_child(settings)
