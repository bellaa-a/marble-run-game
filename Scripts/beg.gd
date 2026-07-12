extends Control

@onready var timer_label: Label = $Timer
@onready var code_container: HBoxContainer = $CodeContainer
@onready var error_label: Label = $Error

var verification_code: String = ""
var time_left := 20


func _ready():
	verification_code = await Multiplayer.get_code()
	start_timer()


func start_timer():
	time_left = 20
	timer_label.text = str(time_left)

	while time_left > 0:
		await get_tree().create_timer(1.0).timeout
		time_left -= 1
		timer_label.text = str(time_left)

	# Timer finished
	queue_free()


func _on_submit_pressed() -> void:
	var entered_code := ""
	error_label.text = ""
	
	for digit in code_container.get_children():
		entered_code += digit.text
		
	if entered_code.length() != 6:
		error_label.text = "Gotta all 6 digits"
		return

	if entered_code == verification_code:
		queue_free()
	else:
		error_label.text = "Either you're trying to guess or your opponent is trolling"
