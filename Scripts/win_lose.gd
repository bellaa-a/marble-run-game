extends Node2D

@export var result: String
@export var message: String
@onready var waiting_label = $CanvasLayer/Control/WaitingLabel
@onready var result_label = $CanvasLayer/Control/Result
@onready var message_label = $CanvasLayer/Control/Message
var frames = [0, 1, 2, 3, 4, 5, 5, 5]
var frame = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	result_label.text = result
	message_label.text = message
	Multiplayer.opponent_home_pressed.connect(_on_opponent_home_pressed)
	Multiplayer.both_players_restart.connect(_on_both_players_restart)


func _on_timer_timeout() -> void:
	waiting_label.visible = true
	frame = (frame + 1) % frames.size()
	waiting_label.text = "Waiting for other player" + ".".repeat(frames[frame])

func _on_restart_button_pressed():
	print("pressed")
	$Click.play()
	await $Click.finished
	Multiplayer.set_restart.rpc()
	$Timer.start()


func _on_home_button_pressed():
	Multiplayer.go_home.rpc()
	Multiplayer.leave_lobby()
	transition.fade_to_scene("res://Scenes/rooms.tscn")
	

func _on_opponent_home_pressed():
	queue_free()
	#show opponent disconnected scene


func _on_both_players_restart():
	transition.fade_to_scene("res://Scenes/connected.tscn")
	
