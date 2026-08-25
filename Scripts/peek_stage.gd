extends Node2D

@export var group_name: String
@export var scene_type: Enum.SceneType
@onready var pipe = $Pipe
@onready var goal = $MultiplayerGoal
@onready var timer_label: Label = $TimerLabel

var opponent_blocks = {}
var win_lose_scene = preload("res://UI/win_lose.tscn")

var time_left := 0.0
var timer_finished := false


func _ready():
	pipe.global_position = Multiplayer.pipe_position
	goal.global_position = Multiplayer.goal_position
	$Peek.global_position = pipe.global_position + Vector2(13, 15)
	
	time_left = Multiplayer.stage_one_time_left
	update_timer_display()
	
	Multiplayer.opponent_block_updated.connect(update_blocks)
	Multiplayer.finish_state_updated.connect(_on_finish_state_updated)

	update_blocks()


func _process(delta):
	if time_left > 0:
		time_left -= delta
		time_left = max(time_left, 0)

		Multiplayer.stage_one_time_left = time_left

	update_timer_display()


func update_timer_display():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]

	if time_left <= 30:
		timer_label.add_theme_color_override("font_color", Color("822726ff")) # red)
	else:
		timer_label.add_theme_color_override("font_color", Color("312018"))


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
			
		else:

			opponent_blocks[id].global_position = \
				Multiplayer.opponent_block_positions[id]["position"]


func _on_finish_state_updated():
	if Multiplayer.player_finished and Multiplayer.opponent_finished:
		transition.fade_to_scene("res://Scenes/solve_stage.tscn")
	else:
		Multiplayer.win_lose_result = "You won!"
		Multiplayer.win_lose_message = "Your opponent did not complete the first stage before the timer ran out."
		Multiplayer.add_stat_to_achievement("NUM_WINS")
		
		var win_lose = win_lose_scene.instantiate()
		add_child(win_lose)


func _on_timer_timeout() -> void:
	$Label.visible = !$Label.visible
