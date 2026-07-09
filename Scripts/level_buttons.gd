extends Node2D

@export var label_text := "Default Text":
	set(value):
		label_text = value

		if is_node_ready():
			$LevelName.text = value

func _ready():
	$LevelName.text = label_text


func _on_exit_pressed() -> void:
	$Click.play()
	await $Click.finished
	transition.fade_to_scene(GameState.get_current_screen())
