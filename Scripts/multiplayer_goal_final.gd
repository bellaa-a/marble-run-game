extends StaticBody2D

@export var start_open := false

var marble_inside = false


func _ready():
	add_to_group("goal")
	reset_goal()
	Multiplayer.reset_finished_stage()
	Multiplayer.finish_state_updated.connect(_on_finish_state_updated)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("marble"):
		marble_inside = true

		await get_tree().create_timer(2.0).timeout

		if marble_inside:
			win_game()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("marble"):
		marble_inside = false

func win_game():
	if GameState.game_won:
		return

	for marble in get_tree().get_nodes_in_group("marble"):
		marble.freeze = true
		marble.linear_velocity = Vector2.ZERO
		marble.angular_velocity = 0
	
	Multiplayer.player_finished_stage.rpc(true)
	


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


func _on_finish_state_updated():
	if Multiplayer.player_finished:
		transition.switch_to_win_lose(
			"res://Scenes/replay_stage.tscn",
			{
				"result": "You won!",
				"message": "Nice job."
			}
		)
	else:
		transition.switch_to_win_lose(
			"res://Scenes/replay_stage.tscn",
			{
				"result": "You lost!",
				"message": "But that's ok."
			}
		)
