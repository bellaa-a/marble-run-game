extends Node2D

@export var shake_strength := 0.7
@export var group_name := ""

var shake_time := 9.0

@onready var camera: Camera2D = $Camera2D


func _ready():
	$World/Welcome.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	$World/Welcome.freeze = true
	$World/Continue.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	$World/Continue.freeze = true
	$World/Continue/CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(10.0).timeout

	for marble in get_tree().get_nodes_in_group("marble"):
		marble.start()
		
	await get_tree().create_timer(2.0).timeout
	$World/Welcome.freeze = false
	$World/Welcome.sleeping = false
	
	await get_tree().create_timer(2.0).timeout
	$World/Continue/CollisionShape2D.set_deferred("disabled", false)
	$World/Continue.freeze = false
	$World/Continue.sleeping = false
	
		

func start_shake(duration: float):
	shake_time = duration

func _process(delta):
	if shake_time > 0:
		shake_time -= delta

		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		camera.offset = Vector2.ZERO
