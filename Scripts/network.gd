extends Control

@onready var warning_label = $Label
@onready var camera: Camera2D = get_tree().current_scene.get_node("Boarder/Camera2D")

var timer := 0.0
var next_update := 0.0

var glitching := false
var powerup_sender_id: int

var mouse_frozen := false

func _ready():
	randomize()
	schedule_next_update()

	warning_label.text = "CONNECTION ISSUES"
	start_warning()

	await get_tree().create_timer(20.0).timeout
	camera.offset = Vector2.ZERO
	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()


func _process(delta):
	timer += delta

	if timer >= next_update and not glitching:
		timer = 0.0

		if randf() < 0.25:
			start_glitch()

		schedule_next_update()

func _unhandled_input(event):
	if mouse_frozen:
		if event is InputEventMouseMotion or event is InputEventMouseButton:
			get_viewport().set_input_as_handled()


func schedule_next_update():
	next_update = randf_range(0.1, 0.5)


func start_glitch():
	glitching = true
	mouse_frozen = true

	warning_label.text = "CONNECTION ISSUES"

	await RenderingServer.frame_post_draw

	var image = get_viewport().get_texture().get_image()
	var texture = ImageTexture.create_from_image(image)

	var layer = CanvasLayer.new()
	layer.layer = 100
	get_tree().current_scene.add_child(layer)

	var screenshot = TextureRect.new()

	screenshot.position = Vector2.ZERO
	screenshot.size = get_viewport().get_visible_rect().size

	screenshot.texture = texture
	screenshot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screenshot.stretch_mode = TextureRect.STRETCH_SCALE
	screenshot.mouse_filter = Control.MOUSE_FILTER_STOP

	layer.add_child(screenshot)

	await get_tree().create_timer(randf_range(1.0, 2.0)).timeout

	layer.queue_free()

	mouse_frozen = false
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
