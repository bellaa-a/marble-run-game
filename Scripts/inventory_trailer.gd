extends Node2D

@onready var effect_layer = get_tree().current_scene.get_node("EffectLayer")

@onready var hand_cards = [
	$Card1,
	$Card2,
	$Card3,
	$Card4,
	$Card5,
	$Card6,
	$Card7,
	$Card8,
	$Card9,
]

func _ready() -> void:
	$ErrorMessage.text = ""
	load_inventory()


func load_inventory():
	CardDatabase.load_cards()
	hand_cards[0].setup(CardDatabase.necessary_cards.pick_random())
	hand_cards[1].setup(CardDatabase.addon_cards.pick_random())
	hand_cards[2].setup(CardDatabase.addon_cards.pick_random())
	hand_cards[3].setup(CardDatabase.block_cards.pick_random())
	hand_cards[4].setup(CardDatabase.block_cards.pick_random())
	hand_cards[5].setup(CardDatabase.block_cards.pick_random())
	hand_cards[6].setup(CardDatabase.block_cards.pick_random())
	hand_cards[7].setup(CardDatabase.powerup_cards.pick_random())
	hand_cards[8].setup(CardDatabase.powerup_cards.pick_random())


func _on_block_drag_started(card):
	var parent = get_parent()

	if parent.has_method("begin_drag"):
		parent.begin_drag(card)


func _on_powerup_clicked(card: DraftCard):
	
	var result = Multiplayer.can_use_powerup(card)
	if not result["allowed"]:
		$ErrorMessage.text = result["message"]
		await get_tree().create_timer(1).timeout
		$ErrorMessage.text = ""
		return

	Multiplayer.active_powerup = true
	Multiplayer.send_powerup(card.id)
	
	for hand_card in hand_cards:
		if hand_card.card_data == card:
			hand_card.use_card()
			Multiplayer.player_inventory[hand_card.inventory_index]["used"] = true
			break

	if card.id == "beg":
		var authenticator = preload("res://UI/authenticator_code.tscn").instantiate()
		effect_layer.add_child(authenticator)
