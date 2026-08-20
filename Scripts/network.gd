extends Control

@onready var warning_label = $Label
@onready var camera: Camera2D = get_tree().current_scene.get_node("Boarder/Camera2D")

var timer := 0.0
var next_update := 0.0

var glitching := false
var powerup_sender_id: int

var mouse_frozen := false
var glitch_layer: CanvasLayer = null
var warning_tween: Tween = null
var finished := false


func _ready():
	randomize()
	schedule_next_update()

	warning_label.text = "CONNECTION ISSUES"
	start_warning()

	await get_tree().create_timer(20.0).timeout

	finish_powerup()


func _process(delta):
	if finished:
		return

	timer += delta

	if timer >= next_update and not glitching:
		timer = 0.0

		if randf() < 0.15:
			start_glitch()

		schedule_next_update()


func _unhandled_input(event):
	if mouse_frozen:
		if event is InputEventMouseMotion or event is InputEventMouseButton:
			get_viewport().set_input_as_handled()


func schedule_next_update():
	next_update = randf_range(0.5, 1.0)


func start_glitch():
	# Don't allow another glitch while one is already happening
	if glitching or finished:
		return

	glitching = true
	mouse_frozen = true

	warning_label.text = "CONNECTION ISSUES"

	await RenderingServer.frame_post_draw

	# The powerup may have ended while we were waiting
	if finished or not is_inside_tree():
		return

	var image = get_viewport().get_texture().get_image()
	var texture = ImageTexture.create_from_image(image)

	# Create the screenshot layer as a CHILD of this powerup.
	# This guarantees it gets deleted when this powerup is deleted.
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

	await get_tree().create_timer(randf_range(0.5, 1.0)).timeout

	# The powerup may have finished during the glitch
	if is_instance_valid(glitch_layer):
		glitch_layer.queue_free()

	glitch_layer = null

	glitching = false
	mouse_frozen = false


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

	# Stop any active glitch
	glitching = false
	mouse_frozen = false

	# Remove screenshot immediately if one exists
	if is_instance_valid(glitch_layer):
		glitch_layer.queue_free()

	glitch_layer = null

	# Stop warning animation
	if warning_tween:
		warning_tween.kill()
		warning_tween = null

	warning_label.visible = false

	# Reset camera
	if is_instance_valid(camera):
		camera.offset = Vector2.ZERO

	# Tell the player who activated this powerup that it is finished
	if multiplayer.multiplayer_peer and powerup_sender_id != 0:
		Multiplayer.powerup_finished.rpc_id(powerup_sender_id)

	queue_free()
