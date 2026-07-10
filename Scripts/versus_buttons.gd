extends Node2D

@onready var timer_label: Label = $TimerLabel

var time_left := 0.0

@export var label_text := "Default Text":
	set(value):
		label_text = value

		if is_node_ready():
			$LevelName.text = value

func _ready():
	$LevelName.text = label_text
	# Start countdown immediately from selected stage time
	
	time_left = Multiplayer.stage_one_time
	print(time_left)
	await get_tree().create_timer(3.0).timeout
	$Instructions.visible = false


func _process(delta):
	if time_left > 0:
		time_left -= delta
	
	update_timer_display()


func update_timer_display():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	timer_label.text = "%02d:%02d" % [minutes, seconds]

	# Last 30 seconds turns red
	if time_left <= 30:
		timer_label.modulate = Color.RED
	else:
		timer_label.modulate = Color.WHITE
