extends Node2D

@export var group_name: String

@onready var effect_layer = $EffectLayer
@onready var pipe = $Pipe
@onready var marble = $Marble
@onready var goal = $MultiplayerGoal

var opponent_blocks = {}
var opponent_addons = []

func _ready() -> void:
	pipe.global_position = Multiplayer.pipe_position
	marble.set_start_position(Multiplayer.pipe_position + Vector2(0, 20))
	goal.global_position = Multiplayer.goal_position
	GameState.game_won = false
	Multiplayer.rotation_mode = true
	Multiplayer.opponent_peeking = false
	Multiplayer.current_stage = 2
	update_blocks()
	update_addons()


func update_blocks():

	for id in Multiplayer.opponent_block_positions:

		if not opponent_blocks.has(id):

			var data = Multiplayer.opponent_block_positions[id]

			var card = CardDatabase.get_card_by_id(data["card_id"])
			
			var block = card.scene.instantiate()
			add_child(block)

			block.global_position = data["position"]
			block.scale = card.block_scale
			opponent_blocks[id] = block

		else:

			opponent_blocks[id].global_position = \
				Multiplayer.opponent_block_positions[id]["position"]


func update_addons():

	for addon_id in Multiplayer.opponent_addons:

		var addon_data = Multiplayer.opponent_addons[addon_id]

		var block = opponent_blocks[addon_data["block_id"]]

		var card = CardDatabase.get_card_by_id(addon_data["card_id"])

		var addon = card.scene.instantiate()

		addon.set_meta("addon_id", addon_id)
		addon.set_meta("card_id", addon_data["card_id"])

		var addon_holder = block.get_node("AddOns")

		addon_holder.add_child(addon)

		addon.position = addon_data["position"]
		addon.rotation = addon_data["rotation"]
