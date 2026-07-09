extends Node2D

var pressed := false

func _ready():
	add_to_group("buttons")
	add_to_group("open goal")
	$GoalButtonPressed.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble") or body.is_shadow:
		return
	if body.attack:
		return
	pressed = true
	$GoalButton.visible = false
	$GoalButtonPressed.visible = true
		
	if get_tree().current_scene.group_name == "break" and get_tree().current_scene.level_number == 3:
		for goal in get_tree().get_nodes_in_group("goal"):
			goal.close_goal()
	else:
		if not _all_buttons_pressed():
			return
		for goal in get_tree().get_nodes_in_group("goal"):
			goal.open_goal()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
	pressed = false
	$GoalButtonPressed.visible = false
	$GoalButton.visible = true
	$CollisionShape2D.set_deferred("disabled", false)


func _all_buttons_pressed() -> bool:
	for button in get_tree().get_nodes_in_group("open goal"):
		if not button.pressed:
			return false
	return true
