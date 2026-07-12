extends Node2D

var discarded_cards: Array[String] = []
var pending_opponent_cards: Array[String] = []
var num_cards := 9
var selected_pairs := [false, false, false, false]
var current_pair := 0
var finished_picking := false
var opponent_finished_picking := false

var hand_positions := [
	Vector2(-225, 240),
	Vector2(-150, 240),
	Vector2(-75, 240),
	Vector2(0, 240),
]

@onready var pipe = $Pipe
@onready var goal = $MultiplayerGoal
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
	Multiplayer.reset_match()
	add_to_group("draft")
	CardDatabase.load_cards()
	generate_draft()
	
	Multiplayer.player_inventory.append({"id": "open_goal", "used": false})
	
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
		cards[9+i].revealing = true
		cards[9+i].set_interactable(false)

	update_pair_access()
	
	pipe.global_position = Multiplayer.pipe_position
	goal.global_position = Multiplayer.goal_position

	
func generate_draft():
	cards[num_cards-1].setup(CardDatabase.necessary_cards.pick_random())
	randomize()

	var pairs = [0, 1, 2, 3]
	pairs.shuffle()

	var powerup_pair = pairs.pop_back()
	var mixed_pair = pairs.pop_back()
	
	var first = 0

	#for pair in pairs:
		#first = pair * 2
		#cards[first].setup(CardDatabase.block_cards.pick_random())
		#cards[first + 1].setup(CardDatabase.block_cards.pick_random())
#
	#first = powerup_pair * 2
	#cards[first].setup(CardDatabase.powerup_cards.pick_random())
	#cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())
#
	#first = mixed_pair * 2
	#cards[first].setup(CardDatabase.block_cards.pick_random())
	#cards[first + 1].setup(CardDatabase.addon_cards.pick_random())
	for pair in pairs:
		first = pair * 2
		cards[first].setup(CardDatabase.powerup_cards.pick_random())
		cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())

	first = powerup_pair * 2
	cards[first].setup(CardDatabase.powerup_cards.pick_random())
	cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())

	first = mixed_pair * 2
	cards[first].setup(CardDatabase.powerup_cards.pick_random())
	cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())


	for i in range(8):
		cards[i].pair_id = floori(i / 2)
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

	var final_card = await resolve_mystery_card(card)

	Multiplayer.player_inventory.append({
		"id": final_card.id,
		"used": false
	})
	
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

	finished_picking = true

	$Instructions.text = "Waiting for opponent to finish picking..."

	Multiplayer.send_discarded_cards.rpc(discarded_cards)

	# Opponent may have already finished
	if opponent_finished_picking:
		await show_opponent_cards()
		try_finish_draft()


func receive_opponent_cards(card_ids: Array[String]):

	print("Received opponent cards:", card_ids)

	# Store exactly what opponent discarded
	pending_opponent_cards = card_ids
	opponent_finished_picking = true

	if not finished_picking:
		return

	await show_opponent_cards()
	try_finish_draft()

func show_opponent_cards():

	$Instructions.text = "Here are the cards from your opponent!"
	await get_tree().create_timer(1.0).timeout

	var reveal_slots = [
		Vector2(-225, 0),
		Vector2(-75, 0),
		Vector2(75, 0),
		Vector2(225, 0),
	]

	var opponent_slots = [
		Vector2(75,240),
		Vector2(150,240),
		Vector2(225,240),
		Vector2(300,240),
	]

	for i in range(pending_opponent_cards.size()):
		var card_id = pending_opponent_cards[i]

		var card = CardDatabase.get_card_by_id(card_id)

		# Show the actual card first (including mystery)
		cards[9+i].setup(card)

		await cards[9+i].reveal_card(
			reveal_slots[i]
		)

		# If mystery, transform after reveal
		if card_id == "mystery":

			var resolved_card = await resolve_mystery_card(cards[9+i])

			Multiplayer.player_inventory.append({
				"id": resolved_card.id,
				"used": false
			})

		else:
			Multiplayer.player_inventory.append({
				"id": card.id,
				"used": false
			})

	await get_tree().create_timer(0.5).timeout

	for i in range(pending_opponent_cards.size()):

		cards[9+i].move_to_hand(
			opponent_slots[i]
		)

	await get_tree().create_timer(0.3).timeout

	
func try_finish_draft():

	if not finished_picking:
		return

	if not opponent_finished_picking:
		return

	print("Both players finished draft!")
	$Instructions.visible = false

	# move to next stage here
	get_tree().change_scene_to_file("res://Scenes/build_stage.tscn")
	

func reveal_pair(pair: int):
	cards[pair * 2].set_revealed(true)
	cards[pair * 2 + 1].set_revealed(true)


func resolve_mystery_card(card):
	if card.card_data.id != "mystery":
		return card.card_data

	# Let the player see the mystery card
	await get_tree().create_timer(0.5).timeout

	# Pick final result first
	var final_powerup = CardDatabase.powerup_cards.pick_random()

	# Random flashing animation
	for i in range(5):
		card.setup(CardDatabase.powerup_cards.pick_random())
		await get_tree().create_timer(0.1).timeout

	# Set final card
	card.setup(final_powerup)
	await get_tree().create_timer(1).timeout

	return final_powerup
