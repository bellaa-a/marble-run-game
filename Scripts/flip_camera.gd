extends Control

@onready var camera = get_tree().current_scene.get_node("Boarder/Camera2D")


func _ready() -> void:
	await flip_camera(true)

	await get_tree().create_timer(20).timeout

	await flip_camera(false)

	queue_free()


func flip_camera(upside_down: bool):
	var target_rotation = PI if upside_down else 0.0

	# Zoom in
	var zoom_in = create_tween()
	zoom_in.set_trans(Tween.TRANS_QUAD)
	zoom_in.set_ease(Tween.EASE_IN_OUT)

	zoom_in.tween_property(
		camera,
		"zoom",
		Vector2(3.0, 3.0),
		0.75
	)

	await zoom_in.finished


	# Flip
	var flip = create_tween()
	flip.set_trans(Tween.TRANS_QUAD)
	flip.set_ease(Tween.EASE_IN_OUT)

	flip.tween_property(
		camera,
		"rotation",
		target_rotation,
		1.5
	)

	await flip.finished


	# Zoom out
	var zoom_out = create_tween()
	zoom_out.set_trans(Tween.TRANS_QUAD)
	zoom_out.set_ease(Tween.EASE_IN_OUT)

	zoom_out.tween_property(
		camera,
		"zoom",
		Vector2(1.5, 1.5),
		0.75
	)

	await zoom_out.finished
