extends Area2D

@onready var highlight = $Highlight

var occupant: StaticBody2D = null

func is_occupied() -> bool:
	return occupant != null

func _ready() -> void:
	add_to_group("snap_points")

func set_highlight(enabled: bool):
	highlight.visible = true if enabled else false

func get_block():
	return get_parent().get_parent()
