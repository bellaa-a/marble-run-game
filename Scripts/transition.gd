extends CanvasLayer

@onready var anim = $ColorRect/AnimationPlayer

func play_transition(scene_path, restart_music):
	anim.play("fade_out")
	await anim.animation_finished

	get_tree().change_scene_to_file(scene_path)
	
	if restart_music:
		Music.restart_music()

	await get_tree().process_frame
	anim.play("fade_in")
