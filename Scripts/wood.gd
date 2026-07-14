extends AnimatableBody2D

var can_rotate : bool = true
@export var side := "left"
@export var attack := false
@export var attack_number := 0


func _ready():
	add_to_group("wood")


func _marble_can_interact_with_this_block(marble) -> bool:
	if attack:
		return marble.attack and marble.attack_number <= get_tree().current_scene.active_attack_count()

	return not marble.attack


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
	if not _marble_can_interact_with_this_block(body):
		return
	$HitWood.play()
