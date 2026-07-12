extends Control

var verification_code: String = ""

func _ready():
	Multiplayer.generate_code()
	$Label.text = await Multiplayer.get_code()
	start_timer()


func start_timer():
	var time_left = 20
	$Timer.text = str(time_left)

	while time_left > 0:
		await get_tree().create_timer(1.0).timeout
		time_left -= 1
		$Timer.text = str(time_left)

	# Timer finished
	queue_free()
