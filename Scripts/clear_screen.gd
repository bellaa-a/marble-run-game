extends Control

@onready var player1 = $Player1 
@onready var eyes1 = $Player1/Eyes  
@onready var sprite1 = $Player1/Player 
@onready var username1 = $Player1/Username 

@onready var player2 = $Player2
@onready var eyes2 = $Player2/Eyes  
@onready var sprite2 = $Player2/Player 
@onready var username2 = $Player2/Username 

func _ready() -> void:
	if Multiplayer.opponent_is_host():
		username1.text = Multiplayer.get_opponent_name()
		await clear_board(player1, eyes1, sprite1)
	else:
		username2.text = Multiplayer.get_opponent_name()
		await clear_board(player2, eyes2, sprite2)
	Multiplayer.active_powerup = false
	queue_free()


func clear_board(character: Node2D, eyes: Polygon2D, player: AnimatedSprite2D):
	player.play("walk")

	var tween = create_tween()
	tween.tween_property(character, "position:x", character.position.x + 70, 3.0)
	await tween.finished

	player.play("press")

	var clear_button = get_tree().current_scene.get_node("SolveButtons/Buttons/ClearButton")
	var normal = clear_button.texture_normal

	await get_tree().create_timer(0.7).timeout

	clear_button.texture_normal = clear_button.texture_pressed
	get_tree().current_scene.get_node("SolveButtons/Buttons")._on_clear_button_pressed()

	await get_tree().create_timer(1.0).timeout

	clear_button.texture_normal = normal

	player.play_backwards("press")
	await player.animation_finished

	# Flip both visuals
	eyes.scale.x *= -1
	player.scale.x *= -1

	player.play("walk")

	var tween2 = create_tween()
	tween2.tween_property(character, "position:x", character.position.x - 70, 3.0)
	await tween2.finished
