extends Node2D

var shaking := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:

		if event.keycode == KEY_P:
			_on_play_button_pressed()

		elif event.keycode == KEY_R:
			_on_rewind_button_pressed()

		elif event.keycode == KEY_C:
			_on_clear_button_pressed()


func _on_play_button_pressed() -> void:
	if GameState.game_won or GameState.locked:
		return
	GameState.life_loss_pending = false
	
	var light_switch = get_tree().current_scene.get_node_or_null("LightSwitch/Press")
	if light_switch:
		light_switch.disabled = true
	
	for goo in get_tree().get_nodes_in_group("goo"):
		goo.get_node("Area2D").monitoring = true
		goo.set_physics_process(true)
		
	var scene = get_tree().current_scene
	if scene.group_name != "break" or scene.level_number == 4:
		GameState.locked = true
			
	if scene.group_name == "break" and scene.level_number == 4:
		for block in get_tree().get_nodes_in_group("block"):
			if block.get_node("Area2D").has_method("start_wind_rotation"):
				block.get_node("Area2D").start_wind_rotation(0.2) # speed value
		get_tree().current_scene.get_node("Fan").visible = true
		get_tree().current_scene.get_node("Fan/Blow").play("Blow")
		get_tree().current_scene.get_node("FanBase").visible = true
		start_camera_shake()
	$Click.play()
	await $Click.finished
	GameState.num_played += 1
	for marble in get_tree().get_nodes_in_group("marble"):
		if not marble.should_exist:
			continue

		marble.start()
	

func _on_rewind_button_pressed() -> void:
	if GameState.game_won:
		return
		
	$Click.play()
	await $Click.finished
	reset_board()


func _on_clear_button_pressed() -> void:
	if GameState.game_won:
		return
		
	$Click.play()
	await $Click.finished
	
	var scene = get_tree().current_scene
	if scene.group_name == "myself":
		transition.fade_to_scene(scene.scene_file_path)
	else: 
		reset_board()
		for block in get_tree().get_nodes_in_group("block"):
			block.get_node("Area2D").reset_block()

func reset_board():
	GameState.locked = false 
	GameState.game_won = false
	GameState.time = 0.0
	shaking = false
	
	var scene = get_tree().current_scene
	
	var light_switch = scene.get_node_or_null("LightSwitch/Press")
	if light_switch:
		light_switch.disabled = false
		
	if scene.group_name == "break" and scene.level_number == 4:
		for block in get_tree().get_nodes_in_group("block"):
			if block.get_node("Area2D").has_method("stop_wind_rotation"):
				block.get_node("Area2D").stop_wind_rotation()
				
	for ice in get_tree().get_nodes_in_group("ice"):
		ice.reset_ice()
	
	for goal in get_tree().get_nodes_in_group("goal"):
		goal.reset_goal()
	
	var marble_resets := []

	for marble in get_tree().get_nodes_in_group("marble"):
		if not marble.is_at_start():
			marble_resets.append(marble.call("reset_marble"))

	for reset in marble_resets:
		await reset
	
	if scene.group_name == "break" and scene.level_number == 4:
		scene.get_node("Fan").visible = false
		scene.get_node("Fan/Blow").stop()
		scene.get_node("FanBase").visible = false


func start_camera_shake():
	shaking = true

	var camera = get_tree().current_scene.get_node("Boarder/Camera2D")

	while shaking:
		camera.offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		)
		await get_tree().create_timer(0.03).timeout

	camera.offset = Vector2.ZERO
