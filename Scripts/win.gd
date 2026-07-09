extends Node2D


func _on_button_pressed() -> void:
	GameState.locked = false 
	$Click.play()
	await $Click.finished
	#GameState.complete_level()
