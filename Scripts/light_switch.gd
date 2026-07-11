extends Node2D

var on := true

func _on_press_pressed() -> void:
	on = !on

	$On.visible = !$On.visible
	$Off.visible = !$Off.visible

	var lights_off = get_tree().current_scene.get_node("LightsOff/CanvasLayer/Dark")
	lights_off.visible = !lights_off.visible

	for marble in get_tree().get_nodes_in_group("marble"):
		marble.update_light_state()

func press_switch():
	$On.visible = !$On.visible
	$Off.visible = !$Off.visible
