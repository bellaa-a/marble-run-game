extends Node2D

const CARD_FOLDER = "res://Cards/"

var block_cards: Array[DraftCard] = []
var addon_cards: Array[DraftCard] = []
var powerup_cards: Array[DraftCard] = []
var necessary_cards: Array[DraftCard] = []
var discarded_cards: Array[String] = []
var num_cards := 9
var selected_pairs := [false, false, false, false]
var current_pair := 0

var hand_positions := [
	Vector2(-225, 240),
	Vector2(-150, 240),
	Vector2(-75, 240),
	Vector2(0, 240),
]

@onready var cards = [
	$Card1,
	$Card2,
	$Card3,
	$Card4,
	$Card5,
	$Card6,
	$Card7,
	$Card8,
	$Card9,
	$Card10,
	$Card11,
	$Card12,
	$Card13,
]

@onready var cracks = [
	$Crack1,
	$Crack2,
	$Crack3,
	$Crack4,
]

func _ready():
	load_cards()
	generate_draft()
	
	for card in cards:
		if card.in_hand:
			card.z_index = 20
		else:
			card.z_index = 0

	# hide all pairs except first
	for i in range(4):
		var active = i == 0
		
		cards[i * 2].set_revealed(active)
		cards[i * 2 + 1].set_revealed(active)

	update_pair_access()
	
	$Pipe.position = Multiplayer.pipe_position
	$MultiplayerGoal.position = Multiplayer.goal_position


func generate_draft():
	cards[num_cards-1].setup(necessary_cards.pick_random())
	randomize()

	var pairs = [0, 1, 2, 3]
	pairs.shuffle()

	var powerup_pair = pairs.pop_back()
	var mixed_pair = pairs.pop_back()
	
	var first = 0

	for pair in pairs:
		first = pair * 2
		cards[first].setup(block_cards.pick_random())
		cards[first + 1].setup(block_cards.pick_random())

	first = powerup_pair * 2
	cards[first].setup(powerup_cards.pick_random())
	cards[first + 1].setup(powerup_cards.pick_random())

	first = mixed_pair * 2
	cards[first].setup(block_cards.pick_random())
	cards[first + 1].setup(addon_cards.pick_random())


	for i in range(8):
		cards[i].pair_id = i / 2
		cards[i].card_selected.connect(select_card)


func update_pair_access():
	for i in range(4):
		var enabled = i == current_pair
		
		cards[i * 2].set_selectable(enabled)
		cards[i * 2 + 1].set_selectable(enabled)
		cracks[i].z_index = 20 if enabled else 0


func select_card(card):
	$Click.play()
	await $Click.finished
	
	var pair = card.pair_id

	# only current pair can be selected
	if pair != current_pair:
		return
	
	if selected_pairs[pair]:
		return

	selected_pairs[pair] = true
	
	card.move_to_hand(hand_positions[pair])

	# remove the other card
	var other_card

	if cards[pair * 2] == card:
		other_card = cards[pair * 2 + 1]
	else:
		other_card = cards[pair * 2]

	other_card.disappear()
	discarded_cards.append(other_card.card_data.id)

	# remove crack
	cracks[pair].visible = false

	# unlock next pair
	current_pair += 1

	if current_pair < 4:
		reveal_pair(current_pair)
		update_pair_access()
	else:
		send_opponent_cards()


func send_opponent_cards():
	Multiplayer.send_discarded_cards.rpc(discarded_cards)


func receive_opponent_cards(card_ids: Array[String]):

	var opponent_slots = [
		Vector2(75,240),
		Vector2(150,240),
		Vector2(225,240),
		Vector2(300,240),
	]

	for i in range(card_ids.size()):
		var card = get_card_by_id(card_ids[i])

		cards[10+i].setup(card)
		var tween = create_tween()
		tween.tween_property(
			cards[10 + i],
			"position",
			opponent_slots[i],
			0.4
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
func get_card_by_id(id: String) -> DraftCard:

	for card in block_cards:
		if card.id == id:
			return card

	for card in addon_cards:
		if card.id == id:
			return card

	for card in powerup_cards:
		if card.id == id:
			return card

	for card in necessary_cards:
		if card.id == id:
			return card

	return null
	

func load_cards():
	var dir = DirAccess.open(CARD_FOLDER)

	if dir == null:
		print("Could not find card folder")
		return

	for file in dir.get_files():
		if file.ends_with(".tres"):
			var card = load(CARD_FOLDER + file)

			if card is DraftCard:
				match card.type:
					Enum.CardType.BLOCK:
						block_cards.append(card)
					Enum.CardType.ADDON:
						addon_cards.append(card)
					Enum.CardType.POWERUP:
						powerup_cards.append(card)
					Enum.CardType.NECESSARY:
						necessary_cards.append(card)

	print("Loaded:")
	print("  Blocks:", block_cards.size())
	print("  Addons:", addon_cards.size())
	print("  Powerups:", powerup_cards.size())

func reveal_pair(pair: int):
	cards[pair * 2].set_revealed(true)
	cards[pair * 2 + 1].set_revealed(true)
