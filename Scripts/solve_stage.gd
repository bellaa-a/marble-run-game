extends Node2D

@export var group_name: String
var opponent_blocks = {}
@onready var effect_layer = $EffectLayer
@onready var pipe = $Pipe
@onready var marble = $Marble
@onready var goal = $MultiplayerGoal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pipe.global_position = Multiplayer.pipe_position
	marble.set_start_position(Multiplayer.pipe_position + Vector2(0, 20))
	goal.global_position = Multiplayer.goal_position
	GameState.game_won = false
	Multiplayer.rotation_mode = true
	update_blocks()


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
