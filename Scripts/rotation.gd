extends Control

@onready var player1 = $Player1 
@onready var eyes1 = $Player1/Eyes  
@onready var sprite1 = $Player1/Player 
@onready var username1 = $Player1/Username 

@onready var player2 = $Player2
@onready var eyes2 = $Player2/Eyes  
@onready var sprite2 = $Player2/Player 
@onready var username2 = $Player2/Username 

var powerup_sender_id: int


func _ready() -> void:
	$Lock.visible = false
	$LockRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if Multiplayer.opponent_is_host():
		username1.text = Multiplayer.get_opponent_name()
		await only_rotation(player1, eyes1, sprite1)
	else:
		username2.text = Multiplayer.get_opponent_name()
		await only_rotation(player2, eyes2, sprite2)
	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()


func only_rotation(character: Node2D, eyes: Polygon2D, player: AnimatedSprite2D):
	player.play("walk")

	var tween = create_tween()
	tween.tween_property(character, "position:x", character.position.x - 75, 3.0)
	await tween.finished

	player.play("press")

	await get_tree().create_timer(0.7).timeout
	var toggle = get_tree().current_scene.get_node("BuildButtons/Rotation")
	toggle.button_pressed = true
	$Lock.visible = true
	$LockRect.mouse_filter = Control.MOUSE_FILTER_STOP

	await get_tree().create_timer(1.0).timeout


	player.play_backwards("press")
	await player.animation_finished

	# Flip both visuals
	eyes.scale.x *= -1
	eyes.position.x -= 5
	player.scale.x *= -1

	player.play("walk")

	var tween2 = create_tween()
	tween2.tween_property(character, "position:x", character.position.x + 75, 3.0)
	await tween2.finished
	
	await get_tree().create_timer(17.0).timeout
