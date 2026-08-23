extends StaticBody2D

const SPEED_BOOST := 1.25

func _ready():
	add_to_group("buttons")
	#$GravityButtonPressed.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble") or body.is_shadow:
		return

	#$GravityButtonPressed.visible = true
	$SpeedBoost.visible = false
	$CollisionShape2D.set_deferred("disabled", true)

	if body is RigidBody2D:
		body.linear_velocity *= SPEED_BOOST


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return

	#$GravityButtonPressed.visible = false
	$SpeedBoost.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
