extends Node

const CARD_FOLDER = "res://Cards/"
var block_cards: Array[DraftCard] = []
var addon_cards: Array[DraftCard] = []
var powerup_cards: Array[DraftCard] = []
var necessary_cards: Array[DraftCard] = []


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
