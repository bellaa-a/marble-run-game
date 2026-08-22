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
var shader_time := 0.0

func _process(delta):
	shader_time += delta
	
	var shader_material = $Dark.material as ShaderMaterial
	
	if shader_material:
		shader_material.set_shader_parameter("time", shader_time)

func _ready() -> void:
	if Multiplayer.opponent_is_host():
		username1.text = Multiplayer.get_opponent_name()
		await lights_off(player1, eyes1, sprite1)
	else:
		username2.text = Multiplayer.get_opponent_name()
		await lights_off(player2, eyes2, sprite2)
	
	await get_tree().create_timer(18.0).timeout
	
	if Multiplayer.opponent_is_host():
		username1.text = Multiplayer.get_opponent_name()
		await lights_off(player1, eyes1, sprite1)
	else:
		username2.text = Multiplayer.get_opponent_name()
		await lights_off(player2, eyes2, sprite2)
		
	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()


func lights_off(character: Node2D, eyes: Polygon2D, player: AnimatedSprite2D):
	player.play("walk")

	var tween = create_tween()
	tween.tween_property(character, "position:x", character.position.x + 170, 3.0)
	await tween.finished

	player.play("press")

	await get_tree().create_timer(0.7).timeout

	press_switch()
	$Dark.visible = !$Dark.visible
	$Click.play()
	await $Click.finished

	await get_tree().create_timer(1.0).timeout

	player.play_backwards("press")
	await player.animation_finished

	# Flip both visuals
	eyes.scale.x *= -1
	eyes.position.x -= 5
	player.scale.x *= -1

	player.play("walk")

	var tween2 = create_tween()
	tween2.tween_property(character, "position:x", character.position.x - 170, 3.0)
	await tween2.finished
	
	# flip back
	eyes.scale.x *= -1
	eyes.position.x += 5
	player.scale.x *= -1


func press_switch():
	$LightSwitch/On.visible = !$LightSwitch/On.visible
	$LightSwitch/Off.visible = !$LightSwitch/Off.visible
