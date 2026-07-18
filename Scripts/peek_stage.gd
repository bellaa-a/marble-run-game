extends Node2D

@export var group_name: String
@export var scene_type: Enum.SceneType
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
			var block = card.preview_scene.instantiate()
			add_child(block)
			block.set_deferred("global_position", data["position"])
			block.set_deferred("scale", card.block_scale)

			opponent_blocks[id] = block
			
			print("Creating block at:", data["position"])

		else:

			opponent_blocks[id].global_position = \
				Multiplayer.opponent_block_positions[id]["position"]


func _on_finish_state_updated():
	if Multiplayer.player_finished and Multiplayer.opponent_finished:
		print("opponent finished")
		transition.fade_to_scene("res://Scenes/solve_stage.tscn")
	else:
		Multiplayer.win_lose_result = "You won!"
		Multiplayer.win_lose_message =  "Your opponent did not complete this stage before the timer ran out."
		print("opponent didnt finish")
		transition.fade_to_scene("res://UI/win_lose.tscn")


func _on_timer_timeout() -> void:
	$Label.visible = !$Label.visible
