extends Button

@export var level_number : int


func _ready():
	update_button()


func update_button():
	var progress = get_progress()

	if level_number < progress:
		# Completed (green)
		disabled = false
		$Disabled.visible = false
		$Progress.visible = false
		$Complete.visible = true

	elif level_number == progress:
		# Current (playable, normal color)
		disabled = false
		$Disabled.visible = false
		$Complete.visible = false
		$Progress.visible = true

	else:
		# Locked
		#disabled = true
		disabled = false
		$Disabled.visible = true
		$Complete.visible = false
		$Progress.visible = false
		modulate = Color(0.5, 0.5, 0.5)


func get_progress():
	match get_tree().current_scene.group_name:
		"regular":
			return GameState.regular_progress
		"mirror":
			return GameState.mirror_progress
		"gravity":
			return GameState.gravity_progress
		"double":
			return GameState.double_progress
		"timed":
			return GameState.timed_progress
		"break":
			return GameState.break_progress
		"light":
			return GameState.light_progress
		"careful":
			return GameState.careful_progress
		"everything":
			return GameState.everything_progress
		"myself":
			return GameState.myself_progress

	return 0
