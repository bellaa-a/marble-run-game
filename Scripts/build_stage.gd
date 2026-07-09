extends Node2D

@onready var effect_layer = $EffectLayer

var dragging_block: Node2D = null
var dragging_card: DraftCard = null

func _ready():
	Multiplayer.build_stage = self
	$Pipe.position = Multiplayer.pipe_position
	$MultiplayerGoal.position = Multiplayer.goal_position


func _exit_tree():
	if Multiplayer.build_stage == self:
		Multiplayer.build_stage = null
		
func _process(_delta):
	if dragging_block:
		dragging_block.global_position = get_global_mouse_position()
		

func begin_drag(card: DraftCard):
	dragging_card = card

	dragging_block = card.scene.instantiate()
	
	# Add as preview object
	add_child(dragging_block)

	# Make it transparent / ghost version
	if dragging_block.has_method("set_preview"):
		dragging_block.set_preview(true)

	# Start following mouse
	dragging_block.global_position = get_global_mouse_position()


func _unhandled_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if not event.pressed and dragging_block:
				finish_drag()
				

func finish_drag():

	if can_place_block(dragging_block.global_position):

		if dragging_block.has_method("set_preview"):
			dragging_block.set_preview(false)

		# Keep block
		dragging_block = null
		dragging_card = null

	else:
		dragging_block.queue_free()
		dragging_block = null
		dragging_card = null


func can_place_block(pos: Vector2) -> bool:
	return true
