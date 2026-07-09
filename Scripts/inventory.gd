extends Node2D

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
	print(Multiplayer.player_inventory)

	load_inventory()


func load_inventory():

	for card in hand_cards:
		card.hide()

	for i in range(Multiplayer.player_inventory.size()):

		var inventory_card = Multiplayer.player_inventory[i]

		var card_data = CardDatabase.get_card_by_id(
			inventory_card["id"]
		)

		if inventory_card["used"]:
			hand_cards[i].use_card()

		hand_cards[i].setup(card_data)
		hand_cards[i].inventory_index = i
		if inventory_card.used:
			hand_cards[i].use_card()
		hand_cards[i].show()

		if not hand_cards[i].block_drag_started.is_connected(_on_block_drag_started):
			hand_cards[i].block_drag_started.connect(_on_block_drag_started)

		if not hand_cards[i].powerup_clicked.is_connected(_on_powerup_clicked):
			hand_cards[i].powerup_clicked.connect(_on_powerup_clicked)
				

func _on_block_drag_started(card):
	get_parent().begin_drag(card)


func _on_powerup_clicked(card: DraftCard):
	Multiplayer.send_powerup(card.id)
	
	for hand_card in hand_cards:
		if hand_card.card_data == card:
			hand_card.use_card()
			Multiplayer.player_inventory[hand_card.inventory_index]["used"] = true
			break
