extends Node2D

@export var level_one_scene: PackedScene
@export var level_two_scene: PackedScene
@export var level_three_scene: PackedScene
@export var level_four_scene: PackedScene

@export var label_text := "Default Text":
	set(value):
		label_text = value

		if is_node_ready():
			$GroupName.text = value

func _ready():
	$GroupName.text = label_text


func _on_one_pressed() -> void:
	get_tree().current_scene.get_node("Boarder/Click").play()
	transition.fade_to_scene(level_one_scene.resource_path)


func _on_two_pressed() -> void:
	get_tree().current_scene.get_node("Boarder/Click").play()
	transition.fade_to_scene(level_two_scene.resource_path)


func _on_three_pressed() -> void:
	get_tree().current_scene.get_node("Boarder/Click").play()
	transition.fade_to_scene(level_three_scene.resource_path)


func _on_four_pressed() -> void:
	get_tree().current_scene.get_node("Boarder/Click").play()
	transition.fade_to_scene(level_four_scene.resource_path)
