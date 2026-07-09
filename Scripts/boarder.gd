extends Node2D

var hit_floor_threshold = 50


func _ready():
	for child in get_children():
		if child is StaticBody2D:
			child.add_to_group("wall")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
		
	var speed_before = body.previous_velocity.length()
	var speed_after = body.linear_velocity.length()

	var velocity_change = abs(speed_before - speed_after)

	# Approximate impact strength
	var impact_strength = velocity_change * body.mass
	
	if impact_strength >= hit_floor_threshold:
		$Floor/AudioStreamPlayer2D.play()
