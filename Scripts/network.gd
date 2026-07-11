extends Control

@onready var warning_label = $Label
@onready var camera: Camera2D = get_tree().current_scene.get_node("Boarder/Camera2D")

var timer := 0.0
var next_update := 0.0

var glitching := false


func _ready():
	randomize()
	schedule_next_update()

	warning_label.text = "CONNECTION ISSUES"
	start_warning()

	await get_tree().create_timer(20.0).timeout
	camera.offset = Vector2.ZERO
	queue_free()


func _process(delta):
	timer += delta

	if timer >= next_update and not glitching:
		timer = 0.0

		if randf() < 0.15:
			start_glitch()

		schedule_next_update()


func schedule_next_update():
	next_update = randf_range(0.1, 0.5)


func start_glitch():
	glitching = true

	warning_label.text = "CONNECTION ISSUES"

	var tween = create_tween()

	# quick camera jumps
	tween.tween_property(
		camera,
		"offset",
		Vector2(randf_range(-15,15), randf_range(-15,15)),
		0.03
	)

	tween.tween_property(
		camera,
		"offset",
		Vector2(randf_range(-10,10), randf_range(-10,10)),
		0.03
	)

	tween.tween_property(
		camera,
		"offset",
		Vector2.ZERO,
		0.05
	)

	await tween.finished

	camera.offset = Vector2.ZERO

	glitching = false


func start_warning():
	warning_label.visible = true

	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		warning_label,
		"modulate:a",
		0.0,
		0.3
	)

	tween.tween_property(
		warning_label,
		"modulate:a",
		1.0,
		0.3
	)
