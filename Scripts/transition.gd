extends CanvasLayer

@onready var anim = $ColorRect/AnimationPlayer


func fade_out():
	anim.play("fade_out")
	await anim.animation_finished


func fade_in():
	anim.play("fade_in")
	await anim.animation_finished


func play_transition(scene_path, restart_music):

	await fade_out()

	get_tree().change_scene_to_file(scene_path)

	if restart_music:
		Music.restart_music()

	await get_tree().process_frame

	await fade_in()
