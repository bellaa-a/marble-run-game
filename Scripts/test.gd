extends Node2D


@export var group_name : String
@onready var area2d = $OpenGoal/DragArea

func _ready():
	area2d.show_snap_points(false)
	area2d.update_closest_snap()
