extends Node2D

var music_bus := AudioServer.get_bus_index("Music")

func _ready() -> void:
	var start_db := AudioServer.get_bus_volume_db(music_bus)
	var tween := create_tween()

	tween.tween_method(
		func(value: float) -> void:
			AudioServer.set_bus_volume_db(music_bus, value),
		start_db,
		-80.0,
		2.0
	)

	await tween.finished
	AudioServer.set_bus_mute(music_bus, true)
	AudioServer.set_bus_volume_db(music_bus, start_db)
