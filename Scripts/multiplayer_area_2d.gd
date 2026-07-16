extends Area2D

var dragging = false
var blocked = false
var blocked_direction = 0
var direction_probe = 0.0
var ENTERED_LOOP = false

var initial_mouse_angle = 0.0
var initial_block_rotation = 0.0
var previous_mouse_angle = 0.0

const DIRECTION_THRESHOLD = 0.05
const MOVE_THRESHOLD = 1.0

var start_position: Vector2
var start_rotation: float

var rotating := false
var rotation_speed := 0.0
var moving := false
var move_offset := Vector2.ZERO
var previous_position := Vector2.ZERO
var blocked_move := false
var blocked_move_direction := Vector2.ZERO
	

func _ready():
	var block = get_parent()
	block.add_to_group("block")
	
	
func set_start_transform():
	var block = get_parent()
	start_position = block.global_position
	start_rotation = block.global_rotation

func start_wind_rotation(speed: float):
	rotating = true
	rotation_speed = speed
	
	
func stop_wind_rotation():
	rotating = false
	

func reset_block():
	print("reset block")
	#var block = get_parent()

	#block.global_position = start_position
	#block.global_rotation = start_rotation

	blocked = false
	blocked_direction = 0
	direction_probe = 0.0
	ENTERED_LOOP = false
	rotating = false
	moving = false


# ---------------- INPUT ----------------

func _input_event(_viewport, event, _shape_idx):	
	if GameState.locked:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		var block = get_parent()

		if Multiplayer.rotation_mode:

			var center = block.global_position
			var mouse = get_global_mouse_position()

			initial_mouse_angle = (mouse - center).angle()
			initial_block_rotation = block.rotation
			previous_mouse_angle = initial_mouse_angle

			rotating = true
			direction_probe = 0.0

		else:
			"moving"
			moving = true

			blocked_move = false
			blocked_move_direction = Vector2.ZERO

			move_offset = block.global_position - get_global_mouse_position()
			previous_position = block.global_position
			

func _input(event):

	if GameState.locked:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and not event.pressed:
		if moving or rotating:
			send_position_update()

		rotating = false
		moving = false
		direction_probe = 0.0
		blocked_move = false
		blocked_move_direction = Vector2.ZERO


# ---------------- MAIN LOOP ----------------

func _physics_process(delta):
	if Multiplayer.dragging_addon:
		return

	var block = get_parent()

	if rotating:
		block.rotation += rotation_speed * delta

	if moving:
		var old_position = block.global_position

		var target_position = (
			get_global_mouse_position()
			+ move_offset
		)

		var movement = target_position - old_position

		# ---------------- MOVEMENT BLOCKED STATE ----------------

		if blocked_move:
			# moving back opposite the collision direction

			if movement.length() <= MOVE_THRESHOLD:
				return

			var direction = movement.normalized()

			# moving opposite the collision direction
			if direction.dot(blocked_move_direction) < -0.5:
				blocked_move = false
				blocked_move_direction = Vector2.ZERO
			else:
				return

		# ---------------- APPLY MOVEMENT ----------------

		block.global_position = target_position

		if any_movement_collision():

			# revert
			block.global_position = old_position

			blocked_move = true

			# remember the direction that caused the collision
			if movement.length() > 0.001:
				blocked_move_direction = movement.normalized()

		return

	if not dragging or GameState.locked or not block.can_rotate:
		return

	var center = block.global_position
	var mouse = get_global_mouse_position()

	var current_mouse_angle = (mouse - center).angle()

	var mouse_motion = wrapf(current_mouse_angle - previous_mouse_angle, -PI, PI)

	# ---------------- BLOCKED STATE ----------------

	if blocked:

		direction_probe += mouse_motion

		if abs(direction_probe) < DIRECTION_THRESHOLD:
			previous_mouse_angle = current_mouse_angle
			return

		var detected_direction = sign(direction_probe)

		if detected_direction == -blocked_direction:
			blocked = false
			blocked_direction = 0
			direction_probe = 0.0

			initial_mouse_angle = current_mouse_angle
			initial_block_rotation = block.rotation
		else:
			direction_probe = 0.0

		previous_mouse_angle = current_mouse_angle
		return


	# ---------------- APPLY ROTATION (TEMP) ----------------

	var angle_delta = wrapf(current_mouse_angle - initial_mouse_angle, -PI, PI)

	var old_rotation = block.rotation
	var new_rotation = initial_block_rotation + angle_delta
	var rotation_change = new_rotation - old_rotation

	block.rotation = new_rotation
	apply_connected_rotation(rotation_change)

	var colliding = false
	if get_tree().current_scene.group_name != "break" and get_tree().current_scene.group_name != "myself":
		colliding = any_connected_collision()
	else:
		colliding = false

	# ---------------- COLLISION RESOLUTION ----------------

	if not colliding:
		ENTERED_LOOP = false
		
		if abs(rotation_change) > 0.0001:
			wake_marble()

	if colliding and not ENTERED_LOOP:
		ENTERED_LOOP = true

		# revert everything
		block.rotation = old_rotation
		apply_connected_rotation(-rotation_change)

		if mouse_motion > 0.001:
			blocked = true
			blocked_direction = 1
			direction_probe = 0.0

		elif mouse_motion < -0.001:
			blocked = true
			blocked_direction = -1
			direction_probe = 0.0


	previous_mouse_angle = current_mouse_angle


# ---------------- CONNECTED ROTATION ----------------

func apply_connected_rotation(rotation_change: float):

	var block = get_parent()

	for other in get_tree().get_nodes_in_group("block"):

		if other == block:
			continue

		if not same_material(block, other):
			continue
		
		if other.side == block.side:
			continue

		other.rotation -= get_tree().current_scene.mirror_rotation * rotation_change


func same_material(a, b) -> bool:

	if a.is_in_group("wood") and b.is_in_group("wood"):
		return true
	if a.is_in_group("ice") and b.is_in_group("ice"):
		return true
	if a.is_in_group("rubber_band") and b.is_in_group("rubber_band"):
		return true

	return false


# ---------------- COLLISION (FIXED) ----------------

func any_connected_collision() -> bool:

	var space_state = get_world_2d().direct_space_state

	for block in get_connected_blocks():

		var shape_node = block.get_node("CollisionShape2D")
		if shape_node == null or shape_node.shape == null:
			continue

		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = shape_node.shape
		query.transform = shape_node.global_transform

		query.collide_with_bodies = true
		query.collide_with_areas = false

		# IMPORTANT: ignore all connected blocks themselves
		query.exclude = get_connected_rids()

		var results = space_state.intersect_shape(query, 32)

		for hit in results:
			var collider = hit.collider

			if collider.is_in_group("buttons") or collider.is_in_group("goo"):
				continue

			return true

	return false


func get_connected_blocks() -> Array:

	var root = get_parent()
	var result = [root]

	for other in get_tree().get_nodes_in_group("block"):

		if other == root:
			continue

		if same_material(root, other):
			result.append(other)

	return result


func get_connected_rids() -> Array:

	var rids = []

	for b in get_connected_blocks():
		rids.append(b.get_rid())

	return rids


func wake_marble():
	for marble in get_tree().get_nodes_in_group("marble"):
		marble.sleeping = false


func any_movement_collision() -> bool:

	var space_state = get_world_2d().direct_space_state

	var block = get_parent()
	var shape_node = block.get_node("CollisionShape2D")

	if shape_node == null or shape_node.shape == null:
		return false

	var query = PhysicsShapeQueryParameters2D.new()

	query.shape = shape_node.shape
	query.transform = shape_node.global_transform

	query.collide_with_bodies = true
	query.collide_with_areas = false

	# only ignore itself
	query.exclude = [block.get_rid()]

	var results = space_state.intersect_shape(query, 32)

	for hit in results:
		var collider = hit.collider

		if collider == block:
			continue
		
		if collider.is_in_group("buttons") or collider.is_in_group("goo"):
			continue

		return true

	return false


func send_position_update():
	var block = get_parent()
	print("Sending rotation:", block.rotation)
	Multiplayer.sync_block_position.rpc(
		block.get_meta("block_id"),
		block.get_meta("card_id"),
		block.global_position,
		block.rotation
	)
