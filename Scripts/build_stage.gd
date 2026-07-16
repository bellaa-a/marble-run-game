extends Node2D

@onready var effect_layer = $EffectLayer
@onready var pipe = $Pipe
@onready var marble = $Marble
@onready var goal = $MultiplayerGoal
@onready var inventory = $Inventory
@onready var ready_layer = $ReadyLayer
@export var group_name: String

var ready_control_scene = preload("res://UI/ready_control.tscn")
var peek_control_scene = preload("res://UI/peek.tscn")
var ready_control: Control
var peek_control: Control

var dragging_obj: Node2D = null
var dragging_card: Control = null

func _ready():
	pipe.global_position = Multiplayer.pipe_position
	marble.set_start_position(Multiplayer.pipe_position + Vector2(0, 20))
	goal.global_position = Multiplayer.goal_position
	GameState.game_won = false
	Multiplayer.current_stage = 1
	setup_walls()
	show_ready_ui()
	await organize_inventory()
	
	Multiplayer.build_stage = self
	Multiplayer.both_players_ready.connect(_on_both_players_ready)
	Multiplayer.finish_state_updated.connect(_on_finish_state_updated)
	Multiplayer.reset_ready()
	Multiplayer.rotation_mode = false
	

func _exit_tree():
	if Multiplayer.build_stage == self:
		Multiplayer.build_stage = null
		
func _process(_delta):
	if dragging_obj:
		dragging_obj.global_position = get_global_mouse_position()
		
		
func begin_drag(card):

	if Multiplayer.player_inventory[card.inventory_index]["used"]:
		return

	dragging_card = card

	dragging_obj = card.card_data.scene.instantiate()
	dragging_obj.scale = card.card_data.block_scale

	var id = str(randi())

	dragging_obj.set_meta("card_id", card.card_data.id)
	dragging_obj.set_meta("inventory_index", card.inventory_index)

	if card.card_data.type == Enum.CardType.ADDON \
		or card.card_data.type == Enum.CardType.NECESSARY:
		dragging_obj.set_meta("addon_id", id)
		add_child(dragging_obj)
		dragging_obj.global_position = get_global_mouse_position()
		dragging_obj.get_node("DragArea").start_drag()
		dragging_obj = null
		dragging_card = null
		return

	else:
		dragging_obj.set_meta("block_id", id)

	add_child(dragging_obj)

	dragging_obj.global_position = get_global_mouse_position()

	card.card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
func _input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			if dragging_obj:
				finish_drag(dragging_card)
				
func finish_drag(card):

	if dragging_obj == null:
		return

	var obj = dragging_obj
	var card_data = dragging_card.card_data

	if card.card_data.type == Enum.CardType.ADDON \
		or card.card_data.type == Enum.CardType.NECESSARY:
		return

	if can_place_block(obj.global_position):

		card.use_card()
		Multiplayer.player_inventory[card.inventory_index]["used"] = true

		Multiplayer.synch_block_position.rpc(
			obj.get_meta("block_id"),
			obj.get_meta("card_id"),
			obj.global_position,
			obj.rotation
		)


		dragging_obj = null
		dragging_card = null

	else:
		obj.queue_free()


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
	#hide_ready_ui()
	#inventory.z_index = 10
	await get_tree().create_timer(1.0).timeout


func show_ready_ui():
	if ready_control == null:
		ready_control = ready_control_scene.instantiate()
		ready_layer.add_child(ready_control)


func setup_walls():
	for wall in $Walls.get_children():
		var id = wall.name
		wall.set_meta("block_id", id)


func _on_finish_state_updated():
	if Multiplayer.player_finished and Multiplayer.opponent_finished:
		transition.fade_to_scene("res://Scenes/solve_stage.tscn")
	elif Multiplayer.opponent_finished:
		Multiplayer.opponent_peeking = true
		peek_control = peek_control_scene.instantiate()
		effect_layer.add_child(peek_control)
