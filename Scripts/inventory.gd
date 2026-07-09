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

	for i in range(Multiplayer.player_inventory.size()):

		var card_data = CardDatabase.get_card_by_id(
			Multiplayer.player_inventory[i]
		)

		hand_cards[i].setup(card_data)

		hand_cards[i].block_drag_started.connect(_on_block_drag_started)
		hand_cards[i].powerup_clicked.connect(_on_powerup_clicked)
				

func _on_block_drag_started(card: DraftCard):
	get_parent().begin_drag(card)


func _on_powerup_clicked(card: DraftCard):
	Multiplayer.use_powerup.rpc(card.id)
