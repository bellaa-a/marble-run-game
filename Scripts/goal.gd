extends StaticBody2D

@export var start_open := false

var marble_inside = false
var marbles_inside := 0


func _ready():
	add_to_group("goal")
	reset_goal()
	if get_tree().current_scene.group_name == "break" and get_tree().current_scene.level_number == 2:
		$GoalSide/GoalCollision.set_deferred("disabled", true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("marble"):
		marbles_inside += 1

		await get_tree().create_timer(1.0).timeout

		if marbles_inside == get_tree().get_nodes_in_group("marble").size():
			win_game()
			

func win_game():
	if GameState.game_won:
		return

	GameState.game_won = true
	GameState.locked = false 
	GameState.time = 0.0
	
	if get_tree().current_scene.scene_file_path.begins_with(GameState.endTutorial): 
		GameState.didTutorial = true 
		GameState.save_progress()
		
	GameState.complete_level(get_parent().group_name, get_parent().level_number)

	for marble in get_tree().get_nodes_in_group("marble"):
		marble.freeze = true
		marble.linear_velocity = Vector2.ZERO
		marble.angular_velocity = 0

		var tween = get_tree().create_tween()
		tween.set_parallel(true)

		var goal_center = $GoalOpen.global_position + ($GoalOpen.size * 0.5) + Vector2(0, -10)

		tween.tween_property(marble, "global_position", goal_center, 1.5)
		tween.tween_property(marble, "scale", Vector2(0, 0), 1.5)
		tween.tween_property(marble.get_node("OriginalMarble"), "modulate:a", 0.0, 1.0)

	await get_tree().create_timer(1.5).timeout
	transition.fade_to_scene(get_parent().next_scene.resource_path)
	await get_tree().create_timer(0.5).timeout
	
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("marble"):
		marbles_inside -= 1


func reset_goal():
	if not start_open:
		await close_goal()
	else:
		$GoalOpen.visible = true
		$GoalTop/Sprite2D.visible = false
		$GoalTop/GoalCollision.set_deferred("disabled", true)


func close_goal():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($GoalClose, "modulate:a", 1.0, 0.6)
	tween.tween_property($GoalTop/Sprite2D, "modulate:a", 1.0, 0.6)
	await tween.finished

	$GoalOpen.visible = false
	$GoalTop/Sprite2D.visible = true
	$GoalTop/GoalCollision.set_deferred("disabled", false)
	

func open_goal():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($GoalClose, "modulate:a", 0.5, 0.6)
	tween.tween_property($GoalTop/Sprite2D, "modulate:a", 0.0, 0.6)
	await tween.finished
	
	$GoalOpen.visible = true
	$GoalTop/GoalCollision.set_deferred("disabled", true)
	
	for marble in get_tree().get_nodes_in_group("marble"):
		marble.sleeping = false
