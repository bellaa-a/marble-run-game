extends Node2D

@export var max_graffiti := 10

@export var group_name : String
@export var scene_type: Enum.SceneType
@export_file("*.tscn") var next_scene_path : String
@export_file("*.tscn") var last_scene_path : String

func _ready():
	if get_tree().current_scene.name == "Group8":
		update_graffiti()


func update_graffiti():
	var visible_count = min(GameState.num_died, max_graffiti)

	for i in range(1, visible_count + 1):
		var graffiti = get_node("Graffiti%d" % i)
		graffiti.visible = true
		
