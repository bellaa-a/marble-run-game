extends StaticBody2D

@export var start_open := false

var marble_inside = false
@onready var confirm_layer = get_tree().current_scene.get_node("ConfirmLayer")
@onready var buttons = get_tree().current_scene.get_node("BuildButtons/Buttons")
var confirm_control_scene = preload("res://UI/confirm_control.tscn")
var confirm_control: Control

func _ready():
	add_to_group("goal")
	reset_goal()

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
		
	show_confirm_ui()
	
	
func confirmed_goal():
	GameState.game_won = true
	GameState.locked = false

	if confirm_control:
		confirm_control.queue_free()
		confirm_control = null

	for marble in get_tree().get_nodes_in_group("marble"):
		var tween = get_tree().create_tween()
		tween.set_parallel(true)

		var goal_center = $GoalOpen.global_position + ($GoalOpen.size * 0.5) + Vector2(0, -10)

		tween.tween_property(marble, "global_position", goal_center, 1.5)
		tween.tween_property(marble, "scale", Vector2(0, 0), 1.5)
		tween.tween_property(marble.get_node("OriginalMarble"), "modulate:a", 0.0, 1.0)

	await get_tree().create_timer(1.5).timeout
	if Multiplayer.opponent_finished:
		transition.fade_to_scene("res://Scenes/solve_stage.tscn")
	else:
		transition.fade_to_scene("res://Scenes/peek_stage.tscn")
	

func cancel_goal():
	GameState.game_won = false

	if confirm_control:
		confirm_control.hide()

	for marble in get_tree().get_nodes_in_group("marble"):
		marble.freeze = false
		marble.sleeping = false

	buttons._on_rewind_button_pressed()
		

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


func show_confirm_ui():
	if confirm_control == null:
		confirm_control = confirm_control_scene.instantiate()
		confirm_layer.add_child(confirm_control)

		confirm_control.confirmed.connect(confirmed_goal)
		confirm_control.cancelled.connect(cancel_goal)

	confirm_control.show()
