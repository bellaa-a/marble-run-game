extends Node2D

var settings_scene = preload("res://Scenes/settings.tscn")


func _on_settings_pressed() -> void:
	$Click.play()
	await $Click.finished
	var settings = settings_scene.instantiate()
	add_child(settings)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:

		if event.keycode == KEY_ESCAPE:
			_on_settings_pressed()
