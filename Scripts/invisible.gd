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
		await lights_off(player1, eyes1, sprite1)
	else:
		username2.text = Multiplayer.get_opponent_name()
		await lights_off(player2, eyes2, sprite2)
	
	await get_tree().create_timer(20.0).timeout
	Multiplayer.active_powerup = false
	queue_free()


func lights_off(character: Node2D, eyes: Polygon2D, player: AnimatedSprite2D):
	player.play("walk")

	var tween = create_tween()
	tween.tween_property(character, "position:x", character.position.x + 170, 3.0)
	await tween.finished

	player.play("press")

	await get_tree().create_timer(0.7).timeout

	$LightSwitch.press_switch()
	$Lights.visible = true
	$Click.play()
	await $Click.finished

	await get_tree().create_timer(1.0).timeout

	player.play_backwards("press")
	await player.animation_finished

	# Flip both visuals
	eyes.scale.x *= -1
	player.scale.x *= -1

	player.play("walk")

	var tween2 = create_tween()
	tween2.tween_property(character, "position:x", character.position.x - 170, 3.0)
	await tween2.finished
