extends Node2D

@onready var timer_label: Label = $TimerLabel

var time_left := 0.0
var timer_running := false

@export var label_text := "Default Text":
	set(value):
		label_text = value

		if is_node_ready():
			$LevelName.text = value

func _ready():
	$LevelName.text = label_text

	time_left = 0.0
	timer_running = true
	update_timer_display()


func _process(delta):
	if timer_running:
		time_left += delta

	update_timer_display()

func update_timer_display():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]
