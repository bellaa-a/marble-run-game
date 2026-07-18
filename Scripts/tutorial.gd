extends Node2D

@export var group_name : String
@export var scene_type: Enum.SceneType
@export var level_number : int
@export_file("*.tscn") var next_scene_path : String
@export_file("*.tscn") var back_scene_path : String
@export var skip_scene : PackedScene


func _ready() -> void:
	GameState.locked = true
	GameState.game_won = true
	$Buttons/PlayButton.disabled = true
	$Buttons/RewindButton.disabled = true
	$Buttons/ClearButton.disabled = true
	$Description.add_theme_color_override("font_color", Color("c49e63ff"))
