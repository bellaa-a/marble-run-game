extends AnimationPlayer

@onready var stats_label = get_tree().current_scene.get_node("World/StatsLabel")
var music_bus = AudioServer.get_bus_index("Music")

func _ready() -> void:
	stats_label.text = """
	A game by StuffyBells.

	Everything:
	Me (Bella Lu)


	You rolled:
	%s

	You fell:
	%d times

	Sacrificed in goo:
	%d marbles

	You swore:
	Probably

	But you were determined.
	Thank you for playing :)
	""" % [
		format_distance(GameState.length_rolled),
		GameState.num_played,
		GameState.times_in_goo
		]

	play("final")
	AudioServer.set_bus_mute(music_bus, false)
	Music.restart_music()


func _on_animation_finished(_anim_name: StringName) -> void:
	transition.fade_to_scene("res://Scenes/start.tscn")

	

func format_distance(distance: float) -> String:
	if distance >= 1000:
		return str(snapped(distance / 1000.0, 0.1)) + " km"
	else:
		return str(round(distance)) + " m"
