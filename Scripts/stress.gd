extends Control

@onready var camera = get_tree().current_scene.get_node("Boarder/Camera2D")

var shake_time = 20.0
var shake_strength = 1.2
var powerup_sender_id: int

func _ready():
	await get_tree().create_timer(shake_time).timeout
	camera.offset = Vector2.ZERO
	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()


func _process(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta

		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
