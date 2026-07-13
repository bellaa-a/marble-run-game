extends Control

@onready var timer_label: Label = $Timer
@onready var code_container: HBoxContainer = $CodeContainer
@onready var error_label: Label = $Error

var verification_code: String = ""
var time_left := 20


func _ready():
	$Timer.text = str(time_left)
	$CountdownTimer.start()
	verification_code = await Multiplayer.get_code()


func _on_countdown_timer_timeout():
	time_left -= 1
	$Timer.text = str(time_left)

	if time_left <= 0:
		queue_free()


func _on_submit_pressed() -> void:
	var entered_code := ""
	error_label.text = ""
	
	for digit in code_container.get_children():
		entered_code += digit.text
		
	if entered_code.length() != 6:
		error_label.text = "Nope, gotta enter all 6 digits"
		return

	if entered_code == verification_code:
		queue_free()
	else:
		error_label.text = "Either you're trying to guess or your opponent is trolling"
