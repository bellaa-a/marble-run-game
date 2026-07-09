extends Node2D

@onready var music_slider: HSlider = $CanvasLayer/General/MusicSlider
@onready var sound_slider: HSlider = $CanvasLayer/General/SoundSlider
@onready var click: AudioStreamPlayer2D = $CanvasLayer/General/Click

func _ready():
	get_tree().paused = true

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

	queue_free()
	get_tree().paused = false

# -------------------------
# CLOSE WITHOUT SAVING
# -------------------------
func _on_cancel_pressed() -> void:
	click.play()
	await click.finished
	# revert audio back to saved state
	GameState._apply_bus_volume("Music", GameState.music_volume)
	GameState._apply_bus_volume("SFX", GameState.sfx_volume)

	queue_free()
	get_tree().paused = false
	

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
	queue_free()
	get_tree().paused = false
	transition.fade_to_scene("res://Scenes/start.tscn", true)


func _on_home_pressed() -> void:
	_on_cancel_pressed()
	Multiplayer.leave_lobby()
	transition.fade_to_scene("res://Scenes/start.tscn")
