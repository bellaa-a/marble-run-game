extends Node2D

@export var group_name: String

@onready var pipe = $Pipe
@onready var marble = $Marble
@onready var goal = $MultiplayerGoal
@export var result: String
@export var message: String

var opponent_blocks = {}
var opponent_addons = {}

func _ready() -> void:
	pipe.global_position = Multiplayer.pipe_position
	marble.set_start_position(Multiplayer.pipe_position + Vector2(0, 20))
	goal.global_position = Multiplayer.goal_position
	GameState.game_won = false
	Multiplayer.rotation_mode = true
	Multiplayer.opponent_peeking = false
	Multiplayer.current_stage = 2
	setup_walls()
	update_blocks()
	update_addons()
	
	marble.start()


func setup_walls():
	for wall in $Walls.get_children():
		var id = wall.name
		wall.set_meta("block_id", id)
		opponent_blocks[id] = wall
		

func update_blocks():

	for id in Multiplayer.opponent_block_positions:

		var data = Multiplayer.opponent_block_positions[id]

		if not opponent_blocks.has(id):

			var card = CardDatabase.get_card_by_id(data["card_id"])

			var block = card.scene.instantiate()
			add_child(block)
			print("Applying rotation:", data["rotation"])
			block.global_position = data["position"]
			block.rotation = data["rotation"]
			block.scale = card.block_scale

			opponent_blocks[id] = block

		else:
			print("Applying rotation:", data["rotation"])
			opponent_blocks[id].global_position = data["position"]
			opponent_blocks[id].rotation = data["rotation"]

func update_addons():

	for addon_id in Multiplayer.opponent_addons:

		var data = Multiplayer.opponent_addons[addon_id]

		if !opponent_addons.has(addon_id):

			var card = CardDatabase.get_card_by_id(data["card_id"])
			var new_addon = card.preview_scene.instantiate()

			opponent_addons[addon_id] = new_addon

		var addon = opponent_addons[addon_id]

		var block = opponent_blocks[data["block_id"]]
		var holder = block.get_node("AddOns")

		if addon.get_parent() != holder:
			holder.add_child(addon)

		addon.position = data["position"]
		addon.rotation = data["rotation"]

		addon.scale = Vector2(
			1.0 / holder.global_scale.x,
			1.0 / holder.global_scale.y
		)


func _on_timer_timeout() -> void:
	$Label.visible = !$Label.visible
