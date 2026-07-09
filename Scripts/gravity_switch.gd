extends StaticBody2D


func _ready():
	add_to_group("buttons")
	$GravityButtonPressed.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble") or body.is_shadow:
		return
	$GravityButtonPressed.visible = true
	$GravityButton.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	body.gravity_scale *= -1


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
	$GravityButtonPressed.visible = false
	$GravityButton.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
