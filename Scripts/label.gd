extends Label

@export var use_label_text := true
@export var custom_text := ""

@export var type_speed := 0.05

var full_text := ""
var display_text := ""
var index := 0
var is_finished := false

var cursor_visible := true


func _ready():
	if use_label_text:
		full_text = text
	else:
		full_text = custom_text

	text = ""
	_start_typing()
	_blink_cursor()
	
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):  # Enter / Space
		_skip_typing()


func _skip_typing():
	if is_finished:
		return

	is_finished = true
	display_text = full_text
	index = full_text.length()
	_update_text()
	

func _start_typing():
	index = 0
	display_text = ""
	_type_next()


func _type_next():
	if is_finished:
		return

	if index < full_text.length():
		display_text += full_text[index]
		index += 1

		$Type.pitch_scale = randf_range(0.9, 1.1)
		$Type.play()

		_update_text()

		await get_tree().create_timer(type_speed).timeout
		_type_next()
	else:
		is_finished = true


func _blink_cursor():
	while true:
		cursor_visible = !cursor_visible
		_update_text()
		await get_tree().create_timer(0.5).timeout


func _update_text():
	if cursor_visible and index < full_text.length():
		text = display_text + "|"
	else:
		text = display_text
