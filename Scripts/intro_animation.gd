extends AnimationPlayer

@export var next_scene : PackedScene
@export var loop : bool
@export var final : bool
var loops_done := 0
var max_loops := 5
var waiting_for_input := false
var music_bus = AudioServer.get_bus_index("Music")

func _ready() -> void:
	play("intro_scene")
	advance(0)
	AudioServer.set_bus_mute(music_bus, true)
	


func _on_animation_finished(_anim_name: StringName) -> void:
	if loop:
		if loops_done < max_loops - 1:
			loops_done += 1
			play("intro_scene")
		else:
			get_tree().change_scene_to_file(next_scene.resource_path)
	elif final:
		waiting_for_input = true
	else:
		get_tree().change_scene_to_file(next_scene.resource_path)


func _unhandled_input(event):
	if waiting_for_input and event.is_pressed():
		transition.fade_to_scene("res://Scenes/tutorial1a.tscn")
		AudioServer.set_bus_mute(music_bus, false)
