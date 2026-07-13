extends RigidBody2D

var start_position: Vector2
var start_rotation: float
var previous_velocity: Vector2 = Vector2.ZERO
var is_shadow := false
var normal_gravity := 1
var shadow_gravity := -0.1
var should_exist := true
var last_position: Vector2
@export var attack := false
@export var attack_number := 0

func _ready():
	start_position = global_position
	start_rotation = global_rotation
	last_position = global_position

	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	
	add_to_group("marble")
	
	if get_tree().current_scene.group_name == "break":
		continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	
	if get_tree().current_scene.group_name != "myself":
		$MarbleShadow.polygon = make_circle(8, 32)


func set_start_position(pos: Vector2):
	global_position = pos
	start_position = pos
	start_rotation = global_rotation
	
	

func set_shadow_mode(enabled: bool) -> void:
	is_shadow = enabled

	if is_shadow:
		sleeping = false
		linear_velocity.y -= 1
		$OriginalMarble.visible = false
		$MarbleShadow.visible = true
		gravity_scale = shadow_gravity
	else:
		sleeping = false
		$OriginalMarble.visible = true
		gravity_scale = normal_gravity
		

func start():
	freeze = false
	sleeping = false


func reset_marble():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	visible = true
	scale = Vector2.ONE
	$OriginalMarble.modulate.a = 1.0
	
	gravity_scale = 1
	
	set_collision_mask_value(3, false)

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	# disable collision so it cannot hit blocks while flying back
	for shape in find_children("*", "CollisionShape2D", true, false):
		shape.set_deferred("disabled", true)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "global_position", start_position, 0.5)

	await tween.finished

	# snap exactly
	global_position = start_position
	global_rotation = start_rotation

	# re-enable collision after animation
	for shape in find_children("*", "CollisionShape2D", true, false):
		shape.disabled = false
	
	
func is_at_start() -> bool:
	return global_position.distance_to(start_position) < 1.0


func _physics_process(_delta):
	previous_velocity = linear_velocity
	if not attack:
		var distance_moved = global_position.distance_to(last_position)

		# Convert pixels to meters (100 pixels = 1 meter)
		GameState.length_rolled += distance_moved / 100.0

	last_position = global_position


func make_circle(radius: float, segments: int = 32) -> PackedVector2Array:
	var points = PackedVector2Array()

	for i in range(segments):
		var angle = TAU * float(i) / float(segments)
		var p = Vector2(cos(angle), sin(angle)) * radius
		points.append(p)

	return points
