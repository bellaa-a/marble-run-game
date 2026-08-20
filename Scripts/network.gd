extends Control

@onready var warning_label = $Label
@onready var camera: Camera2D = get_tree().current_scene.get_node("Boarder/Camera2D")

var glitching := false
var powerup_sender_id: int

var mouse_frozen := false
var glitch_layer: CanvasLayer = null
var warning_tween: Tween = null
var finished := false


func _ready():
	randomize()

	warning_label.text = "CONNECTION ISSUES"
	start_warning()

	glitch_loop()

	await get_tree().create_timer(20.0).timeout

	finish_powerup()


func glitch_loop():
	while not finished:

		# Wait between glitches
		await get_tree().create_timer(2.0).timeout

		if finished:
			return

		await start_glitch()


func start_glitch():
	if glitching or finished:
		return

	glitching = true
	mouse_frozen = true

	await RenderingServer.frame_post_draw

	if finished or not is_inside_tree():
		return

	var image = get_viewport().get_texture().get_image()
	var texture = ImageTexture.create_from_image(image)

	glitch_layer = CanvasLayer.new()
	glitch_layer.layer = 100
	add_child(glitch_layer)

	var screenshot = TextureRect.new()

	screenshot.position = Vector2.ZERO
	screenshot.size = get_viewport().get_visible_rect().size

	screenshot.texture = texture
	screenshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screenshot.stretch_mode = TextureRect.STRETCH_SCALE
	screenshot.mouse_filter = Control.MOUSE_FILTER_STOP

	glitch_layer.add_child(screenshot)

	# Slight randomness in how long the glitch lasts
	await get_tree().create_timer(
		randf_range(0.4, 0.7)
	).timeout

	if is_instance_valid(glitch_layer):
		glitch_layer.queue_free()

	glitch_layer = null

	glitching = false
	mouse_frozen = false


func _unhandled_input(event):
	if mouse_frozen:
		if event is InputEventMouseMotion or event is InputEventMouseButton:
			get_viewport().set_input_as_handled()


func start_warning():
	warning_label.visible = true

	warning_tween = create_tween()
	warning_tween.set_loops()

	warning_tween.tween_property(
		warning_label,
		"modulate:a",
		0.0,
		0.3
	)

	warning_tween.tween_property(
		warning_label,
		"modulate:a",
		1.0,
		0.3
	)


func finish_powerup():
	if finished:
		return

	finished = true

	glitching = false
	mouse_frozen = false

	if is_instance_valid(glitch_layer):
		glitch_layer.queue_free()

	glitch_layer = null

	if warning_tween:
		warning_tween.kill()
		warning_tween = null

	warning_label.visible = false

	if is_instance_valid(camera):
		camera.offset = Vector2.ZERO

	if multiplayer.multiplayer_peer and powerup_sender_id != 0:
		Multiplayer.powerup_finished.rpc_id(powerup_sender_id)

	queue_free()
