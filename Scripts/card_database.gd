extends Node

var block_cards: Array[DraftCard] = []
var addon_cards: Array[DraftCard] = []
var powerup_cards: Array[DraftCard] = []
var necessary_cards: Array[DraftCard] = []

const ALL_CARD_PATHS = [
	"res://Cards/Small_goo.tres",
	"res://Cards/beg.tres",
	"res://Cards/clear.tres",
	"res://Cards/egg.tres",
	"res://Cards/flip.tres",
	"res://Cards/goo.tres",
	"res://Cards/gravity_switch.tres",
	"res://Cards/invisible.tres",
	"res://Cards/large_ice.tres",
	"res://Cards/large_rubberband.tres",
	"res://Cards/large_wood.tres",
	"res://Cards/lights.tres",
	"res://Cards/lock.tres",
	"res://Cards/medium_ice.tres",
	"res://Cards/medium_rubberband.tres",
	"res://Cards/medium_wood.tres",
	"res://Cards/mystery.tres",
	"res://Cards/network.tres",
	"res://Cards/nothing.tres",
	"res://Cards/open_goal.tres",
	"res://Cards/paint.tres",
	"res://Cards/rotation.tres",
	"res://Cards/small_ice.tres",
	"res://Cards/small_rubberband.tres",
	"res://Cards/small_wood.tres",
	"res://Cards/speed_boost.tres",
	"res://Cards/stress.tres",
]


func load_cards():
	block_cards.clear()
	addon_cards.clear()
	powerup_cards.clear()
	necessary_cards.clear()

	for path in ALL_CARD_PATHS:
		var card = load(path)

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
