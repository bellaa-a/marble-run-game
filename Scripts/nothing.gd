extends Control

var powerup_sender_id: int

func _ready() -> void:
	$Duck.play("walk")
	var tween = create_tween()
	tween.tween_property($Duck, "position:x", $Duck.position.x - 800, 10.0)
	
	$Duck2.play("walk")
	var tween2 = create_tween()
	tween2.tween_property($Duck2, "position:x", $Duck2.position.x - 830, 10.0)
	
	$Duck3.play("walk")
	var tween3 = create_tween()
	tween3.tween_property($Duck3, "position:x", $Duck3.position.x - 820, 10.0)
	
	
	$Quack.play()
	await get_tree().create_timer(0.7).timeout
	$Quack2.play()
	await get_tree().create_timer(0.7).timeout
	$Quack3.play()
	await get_tree().create_timer(9.0).timeout
	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()
