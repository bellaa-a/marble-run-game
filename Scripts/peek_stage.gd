extends Node2D


var opponent_blocks = {}
@onready var pipe = $Pipe
@onready var goal = $MultiplayerGoal

func _ready():
	pipe.global_position = Multiplayer.pipe_position
	goal.global_position = Multiplayer.goal_position
	Multiplayer.opponent_block_updated.connect(update_blocks)
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
