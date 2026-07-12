extends Node2D

@export var result: String
@export var message: String
@onready var waiting_label = $CanvasLayer/Control/RedirectingLabel
@onready var result_label = $CanvasLayer/Control/Result
@onready var message_label = $CanvasLayer/Control/Message
var frames = [0, 1, 2, 3, 4, 5, 5, 5]
var frame = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	result_label.text = result
	message_label.text = message
	await get_tree().create_timer(2).timeout
	transition.fade_to_scene("res://Scenes/rooms.tscn")


func _on_timer_timeout() -> void:
	frame = (frame + 1) % frames.size()
	waiting_label.text = "Redirecting" + ".".repeat(frames[frame])
