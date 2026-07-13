extends Node2D

@onready var waiting_label = $CanvasLayer/Control/RedirectingLabel
var frames = [0, 1, 2, 3, 4, 5, 5, 5]
var frame = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	await get_tree().create_timer(2).timeout
	transition.fade_to_scene("res://Scenes/rooms.tscn")


func _on_timer_timeout() -> void:
	frame = (frame + 1) % frames.size()
	waiting_label.text = "Redirecting" + ".".repeat(frames[frame])
