extends Node2D

@onready var music_slider: HSlider = $CanvasLayer/General/MusicSlider
@onready var sound_slider: HSlider = $CanvasLayer/General/SoundSlider
@onready var click: AudioStreamPlayer2D = $CanvasLayer/General/Click

func _ready():
	#get_tree().paused = true
	GameState.locked = true

	music_slider.value = GameState.music_volume
	sound_slider.value = GameState.sfx_volume

	# --- Apply CURRENT saved GameStatne audio immediately ---
	GameState._apply_bus_volume("Music", GameState.music_volume)
	GameState._apply_bus_volume("SFX", GameState.sfx_volume)


# -------------------------
# LIVE SLIDER PREVIEW
# -------------------------

func _on_music_slider_value_changed(value: float):
	GameState._apply_bus_volume("Music", value)


func _on_sound_slider_value_changed(value: float):
	GameState._apply_bus_volume("SFX", value)


# -------------------------
# SAVE BUTTON (ONLY HERE WE STORE)
# -------------------------
func _on_save_pressed() -> void:
	click.play()
	await click.finished
	GameState.music_volume = music_slider.value
	GameState.sfx_volume = sound_slider.value
	GameState.save_progress()

	#get_tree().paused = false
	GameState.locked = false
	queue_free()

# -------------------------
# CLOSE WITHOUT SAVING
# -------------------------
func _on_cancel_pressed() -> void:
	click.play()
	await click.finished
	# revert audio back to saved state
	GameState._apply_bus_volume("Music", GameState.music_volume)
	GameState._apply_bus_volume("SFX", GameState.sfx_volume)

	#get_tree().paused = false
	GameState.locked = false
	queue_free()
	

func _on_restart_pressed() -> void:
	click.play()
	await click.finished
	$CanvasLayer/General.visible = false
	$CanvasLayer/ConfirmDelete.visible = true


func _on_click_away_pressed() -> void:
	_on_cancel_pressed()


func _on_back_pressed() -> void:
	click.play()
	await click.finished
	$CanvasLayer/General.visible = true
	$CanvasLayer/ConfirmDelete.visible = false


func _on_confirm_pressed() -> void:
	GameState.reset_progress()
	
	#get_tree().paused = false
	GameState.locked = false
	transition.fade_to_scene("res://Scenes/start.tscn", true)
	
	queue_free()

func _on_home_pressed() -> void:
	_on_cancel_pressed()
	Multiplayer.leave_lobby()
	transition.fade_to_scene("res://Scenes/start.tscn")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_on_cancel_pressed()
