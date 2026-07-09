extends Node2D

func _ready() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, true)

	await wait_for_any_input()

	$Start.visible = false
	$StuffyBell.visible = true
	$Name.visible = true
	$StuffyBell.play()
	await get_tree().create_timer(0.5).timeout
	
	$Bell.play()
	await get_tree().create_timer(1.2).timeout
	$Bell.stop()
	$Bell.play()
	await get_tree().create_timer(1.0).timeout
	$Bell.stop()
	$Sneeze.play()
	await $StuffyBell.animation_finished
	await get_tree().create_timer(2.0).timeout
	transition.fade_to_scene("res://Scenes/start.tscn", true)


func wait_for_any_input() -> void:
	while true:
		var event = await get_tree().root.window_input

		if event is InputEventMouseButton and event.pressed:
			return
		elif event is InputEventKey and event.pressed:
			return
		elif event is InputEventJoypadButton and event.pressed:
			return
		elif event is InputEventScreenTouch and event.pressed:
			return
