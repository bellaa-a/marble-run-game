extends StaticBody2D

@export var start_open := false
@export var total_turns := 5

var marbles_inside := []
var checking_attack_win := false
const SETTLED_REQUIRED_TIME := 4.0

var original_marbles_settled_time := 0.0

func _ready():
	add_to_group("goal")
	reset_goal()


func _process(delta: float) -> void:
	if GameState.game_won:
		return

	if _is_original_turn():
		original_marbles_settled_time = 0.0
		return

	if not GameState.locked:
		original_marbles_settled_time = 0.0
		return

	if checking_attack_win:
		return

	if _all_original_marbles_touching_floor():
		original_marbles_settled_time += delta
	else:
		original_marbles_settled_time = 0.0

	var originals_are_done := _all_original_marbles_sleeping() or original_marbles_settled_time >= SETTLED_REQUIRED_TIME

	if originals_are_done and not _original_marble_is_inside_goal():
		_check_attack_win_after_delay()


func _all_original_marbles_touching_floor() -> bool:
	var floor_area := get_tree().current_scene.get_node_or_null("FloorArea")
	if floor_area == null:
		return false

	for marble in get_tree().get_nodes_in_group("marble"):
		if not _is_original_marble(marble):
			continue

		if not marble.visible:
			continue

		if not floor_area.overlaps_body(marble):
			return false

	return true
	

func _check_attack_win_after_delay() -> void:
	checking_attack_win = true

	await get_tree().create_timer(1.0).timeout

	checking_attack_win = false

	if GameState.game_won:
		return

	if _is_original_turn():
		return

	var originals_are_done := _all_original_marbles_sleeping() or original_marbles_settled_time >= SETTLED_REQUIRED_TIME

	if originals_are_done and not _original_marble_is_inside_goal():
		win_turn()
		

func _is_original_turn() -> bool:
	return GameState.myself_turn % 2 == 0


func _is_original_marble(body: Node) -> bool:
	if not body.is_in_group("marble"):
		return false

	if not "attack" in body:
		return true

	return body.attack == false


func _all_original_marbles_sleeping() -> bool:
	for marble in get_tree().get_nodes_in_group("marble"):
		if not _is_original_marble(marble):
			continue

		if marble.visible and not marble.sleeping:
			return false

	return true


func _original_marble_is_inside_goal() -> bool:
	for marble in marbles_inside:
		if is_instance_valid(marble) and _is_original_marble(marble):
			return true

	return false


func _all_original_marbles_are_inside_goal() -> bool:
	for marble in get_tree().get_nodes_in_group("marble"):
		if not _is_original_marble(marble):
			continue

		if not marbles_inside.has(marble):
			return false

	return true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return

	if not marbles_inside.has(body):
		marbles_inside.append(body)

	await get_tree().create_timer(0.7).timeout

	if GameState.game_won:
		return

	if _is_original_turn() and _all_original_marbles_are_inside_goal():
		win_turn()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if marbles_inside.has(body):
		marbles_inside.erase(body)


func win_turn():
	if GameState.game_won:
		return

	GameState.game_won = true
	GameState.locked = false
	GameState.time = 0.0

	if _is_original_turn():
		await _pull_original_marbles_into_goal()
	else:
		await get_tree().create_timer(0.6).timeout

	GameState.myself_turn += 1

	if GameState.myself_turn >= total_turns:
		GameState.complete_level(get_parent().group_name, get_parent().level_number)
		transition.fade_to_scene(get_parent().next_scene.resource_path)
	else:
		GameState.game_won = false
		get_tree().current_scene.apply_myself_turn_state()

	await get_tree().create_timer(0.5).timeout


func _pull_original_marbles_into_goal() -> void:
	for marble in get_tree().get_nodes_in_group("marble"):
		if not _is_original_marble(marble):
			continue

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
