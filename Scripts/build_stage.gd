extends Node2D

@onready var effect_layer = $EffectLayer
@onready var pipe = $Pipe
@onready var marble = $Marble
@onready var goal = $MultiplayerGoal
@onready var inventory = $Inventory
@onready var ready_layer = $ReadyLayer

var ready_control_scene = preload("res://UI/ready_control.tscn")
var ready_control: Control

var dragging_block: Node2D = null
var dragging_card: Control = null

func _ready():
	pipe.global_position = Multiplayer.pipe_position
	marble.set_start_position(Multiplayer.pipe_position + Vector2(0, 20))
	goal.global_position = Multiplayer.goal_position
	
	await organize_inventory()
	show_ready_ui()
	
	Multiplayer.build_stage = self
	Multiplayer.both_players_ready.connect(_on_both_players_ready)
	Multiplayer.reset_ready()
	Multiplayer.rotation_mode = false
	

func _exit_tree():
	if Multiplayer.build_stage == self:
		Multiplayer.build_stage = null
		
func _process(_delta):
	if dragging_block:
		dragging_block.global_position = get_global_mouse_position()
		
		
func begin_drag(card):
	if Multiplayer.player_inventory[card.inventory_index]["used"]:
		return

	dragging_card = card

	dragging_block = card.card_data.scene.instantiate()
	dragging_block.scale = card.card_data.block_scale
	add_child(dragging_block)

	if dragging_block.has_method("set_preview"):
		dragging_block.set_preview(true)

	dragging_block.global_position = get_global_mouse_position()

	# prevent the card from receiving the mouse release
	card.card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
	
func _input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			if dragging_block:
				finish_drag(dragging_card)
				
func finish_drag(card):

	if dragging_block == null:
		return

	var placed_block = dragging_block
	var placed_card = dragging_card

	if can_place_block(placed_block.global_position):

		if placed_block.has_method("set_preview"):
			placed_block.set_preview(false)

		card.use_card()
		Multiplayer.player_inventory[card.inventory_index]["used"] = true
		
		var block_id = str(randi())
		placed_block.set_meta("block_id", block_id)
		placed_block.set_meta("card_id", placed_card.card_data.id)

		Multiplayer.synch_block_position.rpc(
			block_id,
			placed_card.card_data.id,
			placed_block.global_position
		)

		dragging_block = null
		dragging_card = null
		
	else:
		placed_block.queue_free()

	card.card_button.mouse_filter = Control.MOUSE_FILTER_STOP


func can_place_block(_pos: Vector2) -> bool:
	return true


func organize_inventory():
	await animate_cards_to_center()
	sort_player_inventory()
	$Inventory.load_inventory()
	await animate_cards_back()


func animate_cards_to_center():

	var cards = $Inventory.hand_cards

	for card in cards:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(
			card,
			"position",
			Vector2(0,240),
			0.4
		)

	await get_tree().create_timer(0.45).timeout


func animate_cards_back():

	var cards = $Inventory.hand_cards

	for card in cards:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(
			card,
			"position",
			card.normal_position,
			0.4
		)

	await get_tree().create_timer(0.45).timeout
	

func sort_player_inventory():

	var order = {
		Enum.CardType.BLOCK: 0,
		Enum.CardType.NECESSARY: 1,
		Enum.CardType.ADDON: 2,
		Enum.CardType.POWERUP: 3
	}

	Multiplayer.player_inventory.sort_custom(
		func(a, b):
			var card_a = CardDatabase.get_card_by_id(a["id"])
			var card_b = CardDatabase.get_card_by_id(b["id"])

			return order[card_a.type] < order[card_b.type]
	)
	

func _on_both_players_ready():
	print("Everyone is ready!")
	await get_tree().create_timer(2.0).timeout
	$Ready.play()
	await get_tree().create_timer(1.0).timeout
	hide_ready_ui()
	inventory.z_index = 10
	await get_tree().create_timer(1.0).timeout


func show_ready_ui():
	if ready_control == null:
		ready_control = ready_control_scene.instantiate()
		ready_layer.add_child(ready_control)

func hide_ready_ui():
	if ready_control:
		ready_control.queue_free()
		ready_control = null
