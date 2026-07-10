extends Node2D

@onready var timer_label: Label = $TimerLabel

@export var label_text := "Default Text":
	set(value):
		label_text = value

		if is_node_ready():
			$LevelName.text = value

func _ready():
	$LevelName.text = label_text


func _on_rotation_toggled(toggled_on: bool) -> void:
	Multiplayer.rotation_mode = toggled_on


func _process(delta):
	if Multiplayer.stage_one_time > 0:
		Multiplayer.stage_one_time -= delta
	
	update_timer_display()

func update_timer_display():
	var minutes = int(Multiplayer.stage_one_time) / 60
	var seconds = int(Multiplayer.stage_one_time) % 60
	
	timer_label.text = "%02d:%02d" % [minutes, seconds]
