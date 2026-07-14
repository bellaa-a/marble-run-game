extends Control

var generated_answer : int

@onready var math = $Math
@onready var math_error = $Math/Error

@onready var container = $Checklist
@onready var checklist = $Checklist/ScrollContainer/VBoxContainer
@onready var accept_button = $Checklist/Submit
@onready var checklist_error = $Checklist/Error

@onready var playing_cards = $PlayingCards
@onready var upper_label = $PlayingCards/UpperLabel
@onready var lower_suit_label = $PlayingCards/LowerSuitLabel
@onready var lower_rank_label = $PlayingCards/LowerRankLabel
@onready var card_label = $PlayingCards/CardLabel
@onready var message_label = $PlayingCards/MessageLabel
@onready var higher_button = $PlayingCards/HigherButton
@onready var lower_button = $PlayingCards/LowerButton

@onready var typing = $Typing
@onready var paragraph_label = $Typing/ParagraphLabel
@onready var input_box = $Typing/TextEdit
@onready var typing_error = $Typing/Error
var target_text := ""


@onready var suit_buttons = [
	$PlayingCards/DiamondButton,
	$PlayingCards/HeartButton,
	$PlayingCards/SpadeButton,
	$PlayingCards/ClubButton
]

var suits = ["♦", "♥", "♠", "♣"]

var current_card: Dictionary
var game_state := "higher_lower"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var choices = [do_math, do_checkboxes, do_playing_cards, do_typing]

	#var choices = [do_math, do_checkboxes, do_playing_cards, do_typing]
	choices.pick_random().call()


func do_math():
	math.visible = true
	var math_problem = generate_math_question()
	generated_answer = math_problem["answer"]
	print(generated_answer)
	$Math/Question.text = math_problem["question"]

func generate_math_question() -> Dictionary:
	var operations = ["+", "-", "*", "/"]
	var expression_text = str(randi_range(10, 999))

	var num_terms = randi_range(5, 7)

	for i in range(num_terms):
		var op = operations.pick_random()
		var num = randi_range(10, 999)

		expression_text += " " + op + " " + str(num)

	var use_floor = randf() < 0.5

	var question: String
	var answer: int

	var expression = Expression.new()

	if use_floor:
		question = "floor(" + expression_text + ") = ?"
	else:
		question = "ceil(" + expression_text + ") = ?"

	expression.parse(expression_text)
	var result = expression.execute()

	if use_floor:
		answer = floor(result)
	else:
		answer = ceil(result)

	return {
		"question": question,
		"answer": answer
	}


func _on_answer_text_submitted(new_text: String) -> void:
	if not new_text.is_valid_int():
		math_error.text = "Enter an integer"
		return

	if int(new_text) == generated_answer:
		Multiplayer.active_powerup = false
		queue_free()
	else:
		math_error.text = "Incorrect"
		

var normal_terms = [
	"I have read and agree to the Terms and Conditions.",
	"I understand that by continuing, I am entering into a legally binding agreement.",
	"I confirm that I am authorized to use this application.",
	"I agree to use this software responsibly and respectfully.",
	"I confirm that I have backed up important data before continuing.",
	"I understand that this application may contain bugs, glitches, and unexpected behavior.",
	"I acknowledge that the developer is not responsible for any damages caused by misuse.",
	"I agree not to reverse engineer, modify, or exploit this application.",
	"I understand that all decisions made by this application are final.",
	"I confirm that I have reviewed all applicable rules and guidelines.",
	"I agree that my actions while using this application are my responsibility.",
]

var suspicious_terms = [
	"I acknowledge that some buttons may appear more confident than they actually are.",
	"I understand that pressing a button repeatedly will not make it work faster.",
	"I confirm that I have not been forced, bribed, or threatened into accepting these terms.",
	"I acknowledge that there may be small cartoon characters observing my decisions.",
	"I understand that blaming the game after losing may result in the game being disappointed.",
	"I agree that I will not argue with a loading screen.",
	"I confirm that I will treat all menus with respect.",
	"I understand that closing the application will not erase my mistakes.",
	"I acknowledge that the application may remember things I wish it would forget.",
]

var weird_terms = [
	"I understand that somewhere, somehow, a spreadsheet has recorded my actions.",
	"I agree that the imaginary legal department has reviewed this document.",
	"I confirm that no ducks were harmed during the creation of this agreement.",
	"I understand that a tiny lawyer inside the computer has approved this.",
	"I agree not to challenge the authority of the mysterious checkbox council.",
	"I acknowledge that the checkboxes are becoming increasingly important.",
	"I confirm that I am not clicking randomly just to make this end faster.",
	"I understand that the scroll bar has traveled a long journey with me.",
	"I agree that the scroll bar deserves recognition for its hard work.",
	"I acknowledge that the scroll bar may be judging my reading speed.",
	"I promise to thank the scroll bar after completing this process.",
	"I understand that the bottom of this agreement is definitely somewhere below.",
]

var ridiculous_terms = [
	"I acknowledge that this checklist is much longer than necessary.",
	"I understand that this was intentional.",
	"I agree that continuing was my own decision.",
	"I confirm that I have developed a personal relationship with the scroll bar.",
	"I acknowledge that I am now emotionally invested in checking boxes.",
	"I agree that I could have stopped reading at any point but did not.",
	"I understand that every checkbox I click makes the agreement stronger.",
	"I confirm that the previous statement was probably not legally accurate.",
	"I agree not to question why the checklist keeps growing.",
	"I acknowledge that the checklist knows when I am skipping text.",
	"I understand that the final checkbox is definitely not a trap.",
	"I promise I will not immediately uncheck everything after finishing.",
	"I accept responsibility for continuing this far.",
	"I confirm that my finger is tired from clicking.",
	"I acknowledge that my mouse has completed a heroic journey.",
	"I understand that the true treasure was the checkboxes we checked along the way.",
	"I agree that I have read enough legal nonsense for one lifetime.",
	"I confirm that I am ready to proceed.",
]

var final_terms = [
	"FINAL CONFIRMATION: I have read, understood, and accepted this extremely serious and definitely normal agreement.",
	"I accept that pressing the button below means I cannot complain later.",
]


func generate_terms() -> Array[String]:
	var terms: Array[String] = []

	normal_terms.shuffle()
	suspicious_terms.shuffle()
	weird_terms.shuffle()
	ridiculous_terms.shuffle()

	terms.append_array(normal_terms.slice(0, 5))
	terms.append_array(suspicious_terms.slice(0, 5))
	terms.append_array(weird_terms.slice(0, 5))
	terms.append_array(ridiculous_terms.slice(0, 5))

	# Always end with the final confirmations
	terms.append_array(final_terms)

	return terms
	

func do_checkboxes():
	container.visible = true
	for term in generate_terms():
		var checkbox = CheckBox.new()
		checkbox.text = term
		checkbox.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		checkbox.custom_minimum_size = Vector2(400, 40)
		
		checklist.add_child(checkbox)


func _on_submit_pressed() -> void:
	for checkbox in checklist.get_children():
		if not checkbox.button_pressed:
			checklist_error.text = funny_checkbox_error()
			return

	queue_free()


func funny_checkbox_error() -> String:
	var messages = [
		"Please check all boxes. The checkbox council has rejected your application.",
		"ERROR: You attempted to escape the Terms and Conditions. The scroll bar noticed.",
		"Nice try. The unchecked boxes are still waiting for your attention.",
		"The agreement is incomplete. Somewhere, a tiny lawyer is disappointed.",
		"You have not achieved maximum checkbox power yet.",
		"Warning: Missing checkboxes detected. Please negotiate with the remaining boxes.",
		"The final button refuses to work until the checkbox army is satisfied.",
		"You are close. Unfortunately, 'almost all' is not legally recognized.",
		"One or more boxes remain unchecked. They know what you did.",
		"Congratulations! You found the secret requirement: reading everything."
	]

	return messages.pick_random()



func do_playing_cards():
	playing_cards.visible = true
	start_higher_lower()

	for i in range(suit_buttons.size()):
		suit_buttons[i].pressed.connect(
			func(): guess_suit(i)
		)


func create_card() -> Dictionary:
	return {
		"rank": randi_range(1, 10),
		"suit": randi_range(0, 3)
	}


func set_card_display(card: Dictionary):
	var ranks = [
		"",
		"A",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"10",
	]

	var color = Color.RED if card.suit <= 1 else Color.BLACK

	# Top card
	upper_label.text = ranks[card.rank] + "\n" + suits[card.suit]
	upper_label.modulate = color

	# Bottom card
	lower_suit_label.text = suits[card.suit]
	lower_rank_label.text = ranks[card.rank]

	lower_suit_label.modulate = color
	lower_rank_label.modulate = color

	# flip only suit upside down
	lower_suit_label.scale.y = -1
	

# -------------------------
# Higher / Lower
# -------------------------

func start_higher_lower():
	game_state = "higher_lower"

	current_card = create_card()

	set_card_display(current_card)
	message_label.text = "Will the next card be higher or lower?"

	higher_button.visible = true
	lower_button.visible = true

	hide_suits()


func next_card(is_higher_guess: bool):

	var old_card = current_card
	var new_card = create_card()

	while new_card.rank == old_card.rank:
		new_card = create_card()

	current_card = new_card

	var correct = false

	if is_higher_guess:
		correct = new_card.rank > old_card.rank
	else:
		correct = new_card.rank < old_card.rank


	set_card_display(current_card)

	if correct:
		message_label.text = "Correct! That was too easy huh?"
		await get_tree().create_timer(1.0).timeout
		start_suit_game()
	else:
		message_label.text = "Wrong! Guess again."


func _on_higher_button_pressed():
	next_card(true)


func _on_lower_button_pressed():
	next_card(false)


# -------------------------
# Suit guessing
# -------------------------

func start_suit_game():
	upper_label.text = ""
	lower_suit_label.text = ""
	lower_rank_label.text = ""
	
	game_state = "suit"

	message_label.text = "Guess the suit!"

	current_card = create_card()

	card_label.text = "???"

	higher_button.visible = false
	lower_button.visible = false

	show_suits()


func guess_suit(choice: int):

	if choice == current_card.suit:
		card_label.text = ""
		set_card_display(current_card)
		message_label.text = "Correct! I'll let you go for now."
		
		await get_tree().create_timer(1.5).timeout
		queue_free()

	else:
		card_label.text = ""
		set_card_display(current_card)
		message_label.text = "Wrong suit! Try again."

		await get_tree().create_timer(1.5).timeout
		start_suit_game()



func show_suits():
	for button in suit_buttons:
		button.visible = true


func hide_suits():
	for button in suit_buttons:
		button.visible = false


func do_typing():
	typing.visible = true
	var opponent_name = Multiplayer.get_opponent_name()

	var options = [
		"I would like to take a moment to appreciate this incredible experience. This is truly an awesome game, created with passion, creativity, and a ridiculous amount of effort by the developer.",

		"I would like to recognize my opponent, %s. I am thankful that they have given me this opportunity to reflect, compete, and enjoy this moment together. I also remember that the real victory was the friendship and personal growth gained along the way.",

		"I, the undersigned, admit that %s is an incredibly skilled marble engineer. Should I lose this match, I agree that it was entirely because my opponent was simply built different and not because of luck, bad map generation, or suspicious physics.",

		"I acknowledge that all bugs encountered during this match are actually hidden features carefully handcrafted by the developer. Any accidental launches into space, disappearing marbles, or mysterious explosions are considered immersive gameplay experiences.",

		"Before proceeding, I would like to sincerely thank %s for generously allowing me to participate in what will almost certainly become one of the greatest marble matches in recorded history. I will complain loudly if I lose, but deep down I know it was a skill issue.",

		"I hereby agree that if I lose to %s, I will nod respectfully, say 'well played,' and definitely will not spend the next twenty minutes blaming my card draws, the map, the blocks, the gravity, or my internet connection.",

		"I understand that staring intensely at the screen does not increase my marble's intelligence. If my strategy fails against %s, I will accept responsibility instead of pretending I had a completely different plan all along.",

		"I certify that I have read absolutely none of the terms and conditions presented before me. Nevertheless, I fully agree that %s is a respectable opponent and that pressing random buttons confidently is a valid competitive strategy.",

		"I swear that, regardless of the outcome, I will continue telling everyone that I 'almost had it.' Should %s defeat me, I reserve the right to dramatically stare at the replay and claim there was exactly one pixel that changed everything.",

		"I acknowledge that every marble has dreams, ambitions, and feelings. I promise to guide mine responsibly and not launch it directly into the nearest wall. If %s wins, I accept that my marble simply chose a different career path.",

		"By continuing, I agree to pretend that I carefully calculated every move instead of wildly hoping everything would somehow work out. I also agree that %s looks suspiciously competent, which is frankly a little concerning."
	]

	var text = options.pick_random()

	if "%s" in text:
		target_text = text % [opponent_name]
	else:
		target_text = text

	paragraph_label.text = target_text


func _on_submit_typing_pressed():
	if input_box.text == target_text:
		typing_error.text = "Perfect. You have achieved enlightenment."
		await get_tree().create_timer(1.5).timeout
		queue_free()
	else:
		var mistakes = count_differences(input_box.text, target_text)

		typing_error.text = "Incorrect. The developer noticed %d mistakes. Please reflect harder." % mistakes


func count_differences(a: String, b: String) -> int:
	var count = 0
	var length = min(a.length(), b.length())

	for i in range(length):
		if a[i] != b[i]:
			count += 1

	count += abs(a.length() - b.length())

	return count
