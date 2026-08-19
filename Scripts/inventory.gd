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

var powerup_sender_id: int

func _ready() -> void:
	$ErrorMessage.text = ""
	load_inventory()


func load_inventory():

	for card in hand_cards:
		card.hide()

	for i in range(Multiplayer.player_inventory.size()):

		var inventory_card = Multiplayer.player_inventory[i]

		var card_data = CardDatabase.get_card_by_id(
			inventory_card["id"]
		)

		hand_cards[i].setup(card_data)
		hand_cards[i].inventory_index = i
		if inventory_card["used"]:
			hand_cards[i].use_card()
		hand_cards[i].show()

		if not hand_cards[i].block_drag_started.is_connected(_on_block_drag_started):
			hand_cards[i].block_drag_started.connect(_on_block_drag_started)
		
		if not hand_cards[i].powerup_clicked.is_connected(_on_powerup_clicked):
			hand_cards[i].powerup_clicked.connect(_on_powerup_clicked)


func _on_block_drag_started(card):
	var parent = get_parent()

	if parent.has_method("begin_drag"):
		parent.begin_drag(card)


func _on_powerup_clicked(card):

	var result = Multiplayer.can_use_powerup(card)
	
	if not result["allowed"]:
		if result["message"] != "":
			$ErrorMessage.text = result["message"]
			await get_tree().create_timer(1).timeout
			$ErrorMessage.text = ""
		return

	Multiplayer.active_powerup = true

	Multiplayer.player_inventory[card.inventory_index]["used"] = true

	Multiplayer.send_powerup(card.card_data.id)

	card.use_card()

	if card.card_data.id == "beg":
		var authenticator = preload("res://UI/authenticator_code.tscn").instantiate()
		effect_layer.add_child(authenticator)
