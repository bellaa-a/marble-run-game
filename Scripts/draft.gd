extends Node2D

@export var group_name : String
@export var level_number : int
@export var next_scene : PackedScene
@export var skip_scene : PackedScene

func _ready() -> void:
	GameState.locked = false
	

func _process(_delta: float) -> void:
	if group_name != "timed":
		return

	for block in get_tree().get_nodes_in_group("block"):
		var block_timer = block.get_node_or_null("BlockTimer")
		if not block_timer:
			continue

		var usable = block_timer.can_use()

		if not GameState.locked:
			# EDIT MODE (always unlocked)
			for child in block.find_children("*", "CollisionShape2D", true, false):
				child.set_deferred("disabled", false)

			block.modulate = Color.WHITE

			for visual in block.find_children("*", "CanvasItem", true, false):
				if visual != block_timer:
					visual.modulate = Color.WHITE

			continue

		# PLAY MODE
		if usable:
			for child in block.find_children("*", "CollisionShape2D", true, false):
				child.set_deferred("disabled", false)

			block.modulate = Color.WHITE

			for visual in block.find_children("*", "CanvasItem", true, false):
				if visual != block_timer:
					visual.modulate = Color.WHITE

		else:
			for child in block.find_children("*", "CollisionShape2D", true, false):
				child.set_deferred("disabled", true)

			block.modulate = Color(0.4, 0.4, 0.4, 1.0)

			for marble in get_tree().get_nodes_in_group("marble"):
				marble.sleeping = false
