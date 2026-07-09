extends Control

signal card_selected(card)
signal block_drag_started(card)
signal powerup_clicked(card)

@export var in_hand : bool = false
@onready var icon: TextureRect = $Icon
@onready var description: Label = $Description
@onready var stage: Label = $Stage
@onready var card_button: TextureButton = $CardButton
@onready var card_back: Sprite2D = $CardBack
@onready var type: ColorRect = $Type
@onready var question_mark: Label = $CardBack/QuestionMark
@onready var used: Label = $CardBack/Used

var normal_scale := Vector2.ONE
var hover_scale := Vector2(1.4, 1.4)
var normal_position : Vector2
var hover_offset := Vector2(0, -60)
var pair_id: int
var moving_to_hand := false
var dissapearing := false
var card_data: DraftCard

var dragging := false
var drag_threshold := 30
var mouse_down_pos := Vector2.ZERO


func _ready():
	add_to_group("cards")
	pivot_offset = size / 2
	normal_position = position
	question_mark.visible = true
	used.visible = false
	
	card_button.mouse_entered.connect(_on_mouse_entered)
	card_button.mouse_exited.connect(_on_mouse_exited)
	card_button.pressed.connect(_on_pressed)
	card_button.gui_input.connect(_on_card_gui_input)
	

func _on_pressed():
	card_selected.emit(self)
	

func setup(card: DraftCard):
	card_data = card
	
	icon.texture = card.icon
	icon.size = card.icon_size
	icon.position = (size - icon.size) / 2 - Vector2(0, 20)
	
	description.text = card.description
	description.add_theme_font_size_override("font_size", 10)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_constant_override("line_spacing", -3)
	
	stage.text = stage_to_string(card.stage)
	update_type_color()
	
func update_type_color():

	match card_data.type:

		Enum.CardType.BLOCK:
			type.color = Color("6fa8dc96") # blue

		Enum.CardType.ADDON:
			type.color = Color("93c47d96") # green
		
		Enum.CardType.NECESSARY:
			type.color = Color("93c47d96") # green

		Enum.CardType.POWERUP:
			type.color = Color("fa5e7c96") # orange

func stage_to_string(stageName: Enum.Stage) -> String:
	match stageName:
		Enum.Stage.STAGE1:
			return "I"
		Enum.Stage.STAGE2:
			return "II"
		Enum.Stage.BOTH:
			return "I&II"
		_:
			return ""
			
			
func _on_mouse_entered() -> void:
	if moving_to_hand or dissapearing:
		return

	if in_hand:
		for card in get_tree().get_nodes_in_group("cards"):
			card.raise_card()
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)

		tween.tween_property(
			self,
			"scale",
			hover_scale,
			0.15
		)
	
func _on_mouse_exited():
	if moving_to_hand or dissapearing:
		return

	if in_hand:
		for card in get_tree().get_nodes_in_group("cards"):
			card.lower_card()
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)

		tween.tween_property(
			self,
			"scale",
			normal_scale,
			0.15
		)
		

func move_to_hand(target_position: Vector2):
	in_hand = true
	moving_to_hand = true
	set_selected_layer(true)
	
	# reset scale immediately
	scale = normal_scale
	
	# prevent hover events during movement
	card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		self,
		"position",
		target_position,
		0.3
	)
	
	tween.finished.connect(func():
		normal_position = target_position
		moving_to_hand = false
		
		# allow hover again
		card_button.mouse_filter = Control.MOUSE_FILTER_STOP
	)

func reveal_card(target_position: Vector2):

	show()

	position = target_position
	scale = Vector2(1.4, 1.4)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"scale",
		Vector2(1.2, 1.2),
		0.3
	)

	await tween.finished
	
	
func disappear():
	dissapearing = true
	card_button.disabled = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.5
	)

	tween.finished.connect(func():
		dissapearing = false
		hide()
	)
	

func set_selectable(value: bool):
	card_button.disabled = not value

	if value:
		card_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if not in_hand:
			z_index = 10
	else:
		card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		if not in_hand:
			z_index = 0


func set_revealed(value: bool):
	card_back.visible = not value
	question_mark.visible = not value


func raise_card():
	if not in_hand:
		return
		
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"position",
		normal_position + hover_offset,
		0.15
	)


func lower_card():
	if not in_hand:
		return
		
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"position",
		normal_position,
		0.15
	)


func set_selected_layer(value: bool):
	if value:
		z_index = 10
	else:
		z_index = 0


func _on_card_gui_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				mouse_down_pos = event.position
				dragging = true

			else:
				dragging = false

				if card_data.type == Enum.CardType.POWERUP:
					powerup_clicked.emit(card_data)

	elif event is InputEventMouseMotion and dragging:

		if mouse_down_pos.distance_to(event.position) > drag_threshold:

			if card_data.type == Enum.CardType.BLOCK \
			or card_data.type == Enum.CardType.ADDON \
			or card_data.type == Enum.CardType.NECESSARY:

				dragging = false
				block_drag_started.emit(self)

func use_card():
	card_back.visible = true	
	question_mark.visible = false
	used.visible = true
