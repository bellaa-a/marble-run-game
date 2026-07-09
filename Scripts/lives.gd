extends Node


func _ready() -> void:
	update_display()


func minus_life() -> void:
	GameState.lives -= 1
	
	if GameState.lives <= 0:
		update_display()
		await get_tree().create_timer(0.5).timeout
		GameState.careful_progress = 1
		GameState.num_died += 1
		transition.fade_to_scene("res://Scenes/group8.tscn")
		await get_tree().create_timer(0.5).timeout
		reset_lives()
	
	GameState.save_progress()
	update_display()


func reset_lives() -> void:
	GameState.lives = GameState.max_lives
	update_display()


func update_display() -> void:
	var lives = GameState.lives

	$Life1.visible = lives >= 1
	$Life2.visible = lives >= 2
	$Life3.visible = lives >= 3

	$DeadLife1.visible = lives < 1
	$DeadLife2.visible = lives < 2
	$DeadLife3.visible = lives < 3
