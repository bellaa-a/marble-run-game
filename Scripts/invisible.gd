extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for marble in get_tree().get_nodes_in_group("marble"):
		marble.get_node("OriginalMarble").visible = false
	await get_tree().create_timer(20).timeout
	for marble in get_tree().get_nodes_in_group("marble"):
		marble.get_node("OriginalMarble").visible = true
	Multiplayer.active_powerup = false
	queue_free()
