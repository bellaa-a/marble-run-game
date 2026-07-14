extends Control

@export var drip_distance := 150.0
@export var drip_time := 20.0

func _ready():
	$Splatter.play()
	splatter($Splatter1)
	await get_tree().create_timer(0.7).timeout
	$Splatter.play()
	splatter($Splatter2)
	await get_tree().create_timer(0.7).timeout
	$Splatter.play()
	splatter($Splatter3)
	await get_tree().create_timer(drip_time + 1.4).timeout
	Multiplayer.active_powerup = false
	queue_free()
	
	
func splatter(paint: Sprite2D):
	paint.visible = true
	paint.scale = Vector2(0.2, 0.2)
	paint.modulate.a = 0.0

	var start_y = paint.position.y

	var tween = create_tween()

	# SPLAT
	tween.parallel().tween_property(paint, "scale", Vector2(1.35, 1.35), 0.1)
	tween.parallel().tween_property(paint, "modulate:a", 0.7, 0.08)

	# Settle
	tween.tween_property(paint, "scale", Vector2.ONE, 0.12)

	tween.tween_interval(0.5)

	# Drip
	tween.parallel().tween_property(
		paint,
		"position:y",
		start_y + drip_distance,
		drip_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(
		paint,
		"scale:y",
		1.4,
		drip_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(
		paint,
		"scale:x",
		0.85,
		drip_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Fade near the end
	tween.parallel().tween_property(paint, "modulate:a", 0.0, 1.0)\
		.set_delay(drip_time - 1.0)
