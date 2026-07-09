extends Node2D


func _ready():
	start_crack()

func set_reveal(value: float):
	var mat := $CrackSprite.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("reveal_y", value)
	
	
func start_crack():
	var camera = get_tree().current_scene.get_node("Boarder/Camera2D")

	var reveal_duration := 2.5
	var reveal_tween = create_tween()
	reveal_tween.tween_method(set_reveal, 1.0, 0.0, reveal_duration)

	$CrackSound.play()

	# Shake during reveal
	while reveal_tween.is_running():
		camera.offset = Vector2(
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
		await get_tree().create_timer(0.03).timeout

	# Continue shaking after reveal
	var strength := 4.0

	for i in range(20):
		camera.offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)

		strength *= 0.9  # gradually reduce shake
		await get_tree().create_timer(0.03).timeout

	camera.offset = Vector2.ZERO
