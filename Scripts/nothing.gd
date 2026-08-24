extends Control

var powerup_sender_id: int

func _ready() -> void:
	var y_pos = randi_range(-50, 200)
	for i in range(1, 21):
		var duck = get_node("Duck" if i == 1 else "Duck" + str(i))
		
		duck.position.y += y_pos
		duck.play("walk")
		
		var tween = create_tween()
		tween.tween_property(
			duck,
			"position:x",
			duck.position.x - randi_range(1250, 1280),
			15.0
		)
	
	$Quack.play()
	await get_tree().create_timer(0.3).timeout
	$Quack2.play()
	await get_tree().create_timer(0.5).timeout
	$Quack3.play()
	await get_tree().create_timer(0.4).timeout
	$Quack4.play()
	await get_tree().create_timer(0.3).timeout
	$Quack5.play()
	await get_tree().create_timer(13.5).timeout
	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()
