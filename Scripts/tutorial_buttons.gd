extends Node2D

@export var label_text := "Default Text":
	set(value):
		label_text = value

		if is_node_ready():
			$LevelName.text = value

func _ready():
	$LevelName.text = label_text


func _on_skip_pressed() -> void:
	$Click.play()
	await $Click.finished
	if get_tree().current_scene.scene_file_path.begins_with(GameState.endTutorial):
		GameState.didTutorial = true
		GameState.save_progress()
		
	transition.fade_to_scene(get_tree().current_scene.skip_scene.resource_path)
