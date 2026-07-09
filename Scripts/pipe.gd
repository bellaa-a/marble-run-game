extends StaticBody2D

@export var attack := false
@export var attack_number := 0


func _ready():
	add_to_group("pipe")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("marble"):
		body.set_collision_mask_value(3, true) # pipe collision layer
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("marble"):
		body.set_collision_mask_value(3, false) # pipe collision layer
