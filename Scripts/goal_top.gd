extends StaticBody2D

@export var start_open := false

func _ready():
	$GoalTop.visible = not start_open
	$GoalTop/CollisionShape2D.set_deferred("disabled", start_open)
