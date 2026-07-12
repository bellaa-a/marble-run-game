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

	time_left = Multiplayer.stage_one_time
	update_timer_display() # Show the initial time immediately

	Multiplayer.both_players_ready.connect(_on_both_players_ready)

func _on_both_players_ready():
	await get_tree().create_timer(2.5).timeout
	timer_running = true

func _process(delta):
	if timer_running and time_left > 0:
		time_left -= delta
		time_left = max(time_left, 0)

	update_timer_display()

func update_timer_display():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]

	if time_left <= 30:
		timer_label.modulate = Color.RED
	else:
		timer_label.modulate = Color.WHITE
	
	if time_left <= 0:
		if Multiplayer.opponent_finished:
			print("I loose")
		
		elif Multiplayer.player_finished:
			print("I win")
			
		else:
			print("Tie")


func _on_rotation_toggled(toggled_on: bool) -> void:
	Multiplayer.rotation_mode = toggled_on
