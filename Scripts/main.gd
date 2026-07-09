extends Node2D

@export var group_name : String
@export var level_number : int
@export var next_scene : PackedScene
@export var skip_scene : PackedScene
@export var mirror_rotation := 0.0

@onready var darkness_rect : CanvasItem = get_node_or_null("LightsOff/CanvasLayer/Dark")

const MAX_LIGHTS = 16


func _ready() -> void:
	GameState.locked = false
	GameState.game_won = false

	for marble in get_tree().get_nodes_in_group("marble"):
		marble.set_shadow_mode(false)


func _process(_delta: float) -> void:
	_process_lights()

	if GameState.game_won == true:
		return

	_process_timed_blocks()


func _process_lights() -> void:
	if darkness_rect == null:
		return

	var shader = darkness_rect.material

	if shader == null:
		push_error("DarknessRect has no ShaderMaterial assigned!")
		return

	var lights := []

	for light in get_tree().get_nodes_in_group("light"):
		if light.has_node("SpotLight"):
			lights.append(light)

	var light_count = min(lights.size(), MAX_LIGHTS)

	var points = PackedVector2Array()
	var sizes = []

	for i in range(light_count):
		var light = lights[i]
		var spot_light = light.get_node("SpotLight")
		var poly = spot_light.polygon

		sizes.append(poly.size())

		for p in poly:
			var pos = world_to_light_space(light.to_global(p))
			points.append(pos)

	shader.set_shader_parameter("light_count", light_count)
	shader.set_shader_parameter("light_points", points)
	shader.set_shader_parameter("light_sizes", sizes)


func _process_timed_blocks() -> void:
	for block in get_tree().get_nodes_in_group("block"):
		var block_timer = block.get_node_or_null("BlockTimer")
		if not block_timer:
			continue

		var usable = block_timer.can_use()

		if usable or not GameState.locked:
			# UNLOCK
			for child in block.find_children("*", "CollisionShape2D", true, false):
				if block.is_in_group("ice") and block.is_broken:
					continue
				child.set_deferred("disabled", false)

			for area in block.find_children("*", "Area2D", true, false):
				area.set_deferred("monitoring", true)
				area.set_deferred("monitorable", true)

			block.modulate = Color.WHITE
			block_timer.modulate = Color.WHITE

		else:
			# LOCK
			for child in block.find_children("*", "CollisionShape2D", true, false):
				child.set_deferred("disabled", true)

			for area in block.find_children("*", "Area2D", true, false):
				area.set_deferred("monitoring", false)
				area.set_deferred("monitorable", false)

			block.modulate = Color(0.4, 0.4, 0.4, 1.0)
			block_timer.modulate = Color(2.5, 2.5, 2.5, 1.0)

			for marble in get_tree().get_nodes_in_group("marble"):
				marble.sleeping = false


func world_to_light_space(pos):
	return (get_viewport().get_canvas_transform() * pos) * 2.6 - Vector2(5, 865)
