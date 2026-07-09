extends Node2D

@export var shake_strength := 0.7
@export var group_name := ""

var shake_time := 9.0

@onready var camera: Camera2D = $Camera2D
		

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
