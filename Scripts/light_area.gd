extends Area2D

var marbles_inside := {}

func _ready() -> void:
	add_to_group("LightArea")
	
	
func _on_body_entered(body):
	if body.is_in_group("marble"):
		marbles_inside[body] = true
		body.update_light_state()

func _on_body_exited(body):
	if body.is_in_group("marble"):
		marbles_inside.erase(body)
		body.update_light_state()
	
	
