extends Node2D


func _ready():
	add_to_group("goo")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
	if GameState.life_loss_pending:
		$GooSound.play()
		return
	GameState.life_loss_pending = true
	GameState.timed_progress += 1
	$GooSound.play()
	await get_tree().create_timer(1).timeout
	
	var scene = get_tree().current_scene
	var lives = scene.get_node_or_null("Lives")

	if lives:
		lives.minus_life()
			
	if get_tree().current_scene.group_name == "build":
		scene.get_node("BuildButtons/Buttons").call_deferred("reset_board")
	elif get_tree().current_scene.group_name == "solve":
		scene.get_node("SolveButtons/Buttons").call_deferred("reset_board")
	elif get_tree().current_scene.group_name == "replay":
		scene.get_node("Buttons").call_deferred("reset_board")
	else:
		scene.get_node("LevelButtons/Buttons").call_deferred("reset_board")


func _physics_process(_delta):
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("marble"):
			body.linear_velocity *= 0.5
			body.angular_velocity *= 0.5
