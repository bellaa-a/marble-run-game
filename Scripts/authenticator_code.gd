extends Control

var verification_code: String = ""
var time_left := 20

func _ready():
	$Timer.text = str(time_left)
	$CountdownTimer.start()
	Multiplayer.generate_code()
	$Label.text = await Multiplayer.get_code()


func _on_countdown_timer_timeout():
	time_left -= 1
	$Timer.text = str(time_left)

	if time_left <= 0:
		queue_free()
