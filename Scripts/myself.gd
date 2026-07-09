extends Node2D

@export var group_name : String
@export var level_number : int
@export var next_scene : PackedScene


const MARBLE_LAYER := 1        # Layer 1: Marble
const NORMAL_BLOCK_LAYER := 2  # Layer 2: Blocks
const PIPE_LAYER := 4          # Layer 3: Pipes
const WALLS_LAYER := 8         # Layer 4: Walls
const GOAL_LAYER := 16         # Layer 5: Goal
const ADDONS_LAYER := 32       # Layer 6: Addons
const ATTACK_BLOCK_LAYER := 64 # Layer 7: AttackBlocks

const SHARED_MARBLE_MASK := MARBLE_LAYER | PIPE_LAYER | WALLS_LAYER | GOAL_LAYER | ADDONS_LAYER


func _ready() -> void:
	GameState.locked = false
	GameState.game_won = false
	GameState.current_attack = false
	GameState.myself_turn = 0

	_apply_block_collision_layers()
	_apply_turn_state()
	_apply_pipe_state()


func apply_myself_turn_state() -> void:
	GameState.locked = false
	await get_tree().current_scene.get_node("LevelButtons/Buttons").reset_board()

	_apply_block_collision_layers()
	_apply_turn_state()
	_apply_pipe_state()


func _apply_block_collision_layers() -> void:
	for block in get_tree().get_nodes_in_group("block"):
		if not "attack" in block:
			continue

		var block_layer := ATTACK_BLOCK_LAYER if block.attack else NORMAL_BLOCK_LAYER
		block.collision_layer = block_layer

		for child in block.find_children("*", "CollisionObject2D", true, false):
			child.collision_layer = block_layer
			

func _apply_turn_state() -> void:
	var original_turn := is_original_turn()
	var attack_count := active_attack_count()

	for block in get_tree().get_nodes_in_group("block"):
		if not "attack" in block:
			continue

		var can_use := false
		var can_rotate := false

		if block.attack == false:
			can_use = original_turn
			can_rotate = original_turn
		else:
			can_use = not original_turn
			can_rotate = not original_turn and block.attack_number >= attack_count

		# Draw usable blocks on top
		block.z_index = 10 if can_use else 0

		block.modulate = Color.WHITE if can_use else Color(0.4, 0.4, 0.4, 1.0)

		if "can_rotate" in block:
			block.can_rotate = can_rotate
		
		if block.attack and not original_turn:
			var cuff = block.get_node_or_null("Cuff")
			var cuff_2 = block.get_node_or_null("Cuff2")

			if cuff:
				cuff.visible = not can_rotate

			if cuff_2:
				cuff_2.visible = not can_rotate

	for marble in get_tree().get_nodes_in_group("marble"):
		if not "attack" in marble:
			continue

		var should_exist := false

		marble.collision_layer = MARBLE_LAYER

		if marble.attack == false:
			should_exist = true
			marble.collision_mask = SHARED_MARBLE_MASK | NORMAL_BLOCK_LAYER
			marble.modulate = Color.WHITE if original_turn else Color(0.4, 0.4, 0.4, 1.0)
		else:
			should_exist = marble.attack_number <= attack_count
			marble.collision_mask = SHARED_MARBLE_MASK | ATTACK_BLOCK_LAYER
			marble.modulate = Color(1.0, 0.556, 0.531, 1.0)

		marble.visible = should_exist
		marble.should_exist = should_exist

		for shape in marble.find_children("*", "CollisionShape2D", true, false):
			shape.set_deferred("disabled", not should_exist)

		marble.sleeping = not should_exist


func _apply_pipe_state() -> void:
	var original_turn := is_original_turn()
	for pipe in get_tree().get_nodes_in_group("pipe"):
		if not "attack" in pipe:
			continue

		var should_exist := _should_attack_object_exist(pipe)

		pipe.visible = should_exist

		if pipe.attack:
			pipe.modulate = Color(1.0, 0.556, 0.531, 1.0) if not original_turn else Color(0.643, 0.203, 0.201, 1.0)
		else:
			pipe.modulate = Color.WHITE if original_turn else Color(0.4, 0.4, 0.4, 1.0)

		for shape in pipe.find_children("*", "CollisionShape2D", true, false):
			shape.set_deferred("disabled", not should_exist)

		for area in pipe.find_children("*", "Area2D", true, false):
			area.set_deferred("monitoring", should_exist)
			area.set_deferred("monitorable", should_exist)


func _should_attack_object_exist(node) -> bool:
	if not "attack" in node:
		return true

	if node.attack == false:
		return true

	return node.attack_number <= active_attack_count()


func is_original_turn() -> bool:
	return GameState.myself_turn % 2 == 0


func active_attack_count() -> int:
	return int(ceil(GameState.myself_turn / 2.0))
