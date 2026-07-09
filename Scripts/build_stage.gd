extends Node2D

@onready var effect_layer = $EffectLayer
@export var group_name : String

var dragging_block: Node2D = null
var dragging_card: Control = null

func _ready():
	Multiplayer.build_stage = self
	$Pipe.position = Multiplayer.pipe_position
	$Marble.position = Multiplayer.pipe_position + Vector2(0, 20)
	$MultiplayerGoal.position = Multiplayer.goal_position
	await organize_inventory()


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
	add_child(dragging_block)

	if dragging_block.has_method("set_preview"):
		dragging_block.set_preview(true)

	dragging_block.global_position = get_global_mouse_position()

	# prevent the card from receiving the mouse release
	card.card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	

func finish_drag(card):

	if dragging_block == null:
		return

	var placed_block = dragging_block
	dragging_block = null

	if can_place_block(placed_block.global_position):

		if placed_block.has_method("set_preview"):
			placed_block.set_preview(false)

		card.use_card()
		Multiplayer.player_inventory[card.inventory_index]["used"] = true

	else:
		placed_block.queue_free()

	dragging_card = null


func can_place_block(pos: Vector2) -> bool:
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
