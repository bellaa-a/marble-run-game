extends Node2D

@export var group_name: String
var opponent_blocks = {}
@onready var pipe = $Pipe
@onready var goal = $MultiplayerGoal

func _ready():
	pipe.global_position = Multiplayer.pipe_position
	goal.global_position = Multiplayer.goal_position
	Multiplayer.opponent_block_updated.connect(update_blocks)
	Multiplayer.finish_state_updated.connect(_on_finish_state_updated)

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
			
			print("Creating block at:", data["position"])

		else:

			opponent_blocks[id].global_position = \
				Multiplayer.opponent_block_positions[id]["position"]


func _on_finish_state_updated():
	if Multiplayer.player_finished and Multiplayer.opponent_finished:
		transition.fade_to_scene("res://Scenes/solve_stage.tscn")
	else:
		transition.switch_to_win_lose(
			"res://UI/win_lose.tscn",
			{
				"result": "You won!",
				"message": "Your opponent did not complete this stage before the timer ran out."
			}
		)
