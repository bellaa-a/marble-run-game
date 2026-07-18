extends Node2D

var discarded_cards: Array[String] = []
var pending_opponent_cards: Array[String] = []
var num_cards := 9
var selected_pairs := [false, false, false, false]
var current_pair := 0
var finished_picking := false
var opponent_finished_picking := false
#var revealed_cards := []
var choosing_card := false
var music_bus := AudioServer.get_bus_index("Music")

@export var group_name: String
@export var scene_type: Enum.SceneType

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


func _ready():
	AudioServer.set_bus_mute(music_bus, false)
	add_to_group("draft")
	CardDatabase.load_cards()
	generate_draft()
	
	Multiplayer.player_inventory.append({"id": "open_goal", "used": false})
	
	for card in cards:
		if card.in_hand:
			card.z_index = 20
		else:
			card.z_index = 0

	for i in range(4):
		var active = i == 0

		var card_a = cards[i * 2]
		var card_b = cards[i * 2 + 1]

		card_a.visible = active
		card_b.visible = active
		
		card_a.scale = Vector2(1.6,1.6)
		card_b.scale = Vector2(1.6,1.6)

		#card_a.set_revealed(false)
		#card_b.set_revealed(false)
			
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

	for pair in pairs:
		first = pair * 2
		cards[first].setup(CardDatabase.block_cards.pick_random())
		cards[first + 1].setup(CardDatabase.block_cards.pick_random())

	first = powerup_pair * 2
	cards[first].setup(CardDatabase.powerup_cards.pick_random())
	cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())

	first = mixed_pair * 2
	cards[first].setup(CardDatabase.block_cards.pick_random())
	cards[first + 1].setup(CardDatabase.addon_cards.pick_random())
	
	#for pair in pairs:
		#first = pair * 2
		#cards[first].setup(CardDatabase.powerup_cards.pick_random())
		#cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())
#
	#first = powerup_pair * 2
	#cards[first].setup(CardDatabase.powerup_cards.pick_random())
	#cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())
#
	#first = mixed_pair * 2
	#cards[first].setup(CardDatabase.powerup_cards.pick_random())
	#cards[first + 1].setup(CardDatabase.powerup_cards.pick_random())


	for i in range(8):
		cards[i].pair_id = floori(i / 2)
		cards[i].card_selected.connect(select_card)


func update_pair_access():

	var card_a = cards[current_pair * 2]
	var card_b = cards[current_pair * 2 + 1]

	# only reveal current pair
	card_a.visible = true
	card_b.visible = true

	# only current pair is selectable
	card_a.set_selectable(not choosing_card)
	card_b.set_selectable(not choosing_card)
	
func select_card(card):

	$Click.play()

	var pair = card.pair_id

	if pair != current_pair:
		return

	# Phase 1: reveal cards
	#if not choosing_card:
#
		#if card in revealed_cards:
			#return
#
		##card.set_revealed(true)
		#revealed_cards.append(card)
#
		## wait until both cards are revealed
		#if revealed_cards.size() == 2:
			#choosing_card = true
#
			#for revealed in revealed_cards:
				#revealed.set_selectable(true)
#
		#return


	# Phase 2: choose one of the revealed cards

	var final_card = await resolve_mystery_card(card)

	Multiplayer.player_inventory.append({
		"id": final_card.id,
		"used": false
	})
	await card.move_to_hand(hand_positions[pair])

	var other_card = null

	for c in get_tree().get_nodes_in_group("cards"):
		if c != card and c.pair_id == card.pair_id:
			other_card = c
			break
	#var other_card = revealed_cards[0] if revealed_cards[1] == card else revealed_cards[1]

	await other_card.disappear()
	discarded_cards.append(other_card.card_data.id)

	selected_pairs[pair] = true

	#revealed_cards.clear()
	choosing_card = false


	current_pair += 1

	if current_pair < 4:
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

		await cards[9+i].move_to_hand(
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
	transition.fade_to_scene("res://Scenes/build_stage.tscn")

func resolve_mystery_card(card):
	if card.card_data.id != "mystery":
		return card.card_data
	card.set_interactable(false)
	# Let the player see the mystery card
	await get_tree().create_timer(0.5).timeout

	# Get all non-mystery powerups
	var possible_powerups = CardDatabase.powerup_cards.filter(
		func(c): return c.id != "mystery"
	)

	# Pick the final result
	var final_powerup = possible_powerups.pick_random()

	# Random flashing animation
	for i in range(5):
		card.setup(possible_powerups.pick_random())
		await get_tree().create_timer(0.1).timeout

	# Set final card
	card.setup(final_powerup)
	await get_tree().create_timer(1.0).timeout

	return final_powerup
