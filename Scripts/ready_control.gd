extends Control


@onready var username1 = $Username1
@onready var username2 = $Username2
@onready var ready_button = $ReadyButton
@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var button1 = $Button1On
@onready var button2 = $Button2On
@onready var countdown_label = $CountdownLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Multiplayer.reset_ready()
	var id1 = Steam.getLobbyMemberByIndex(Multiplayer.lobby_id, 0)
	username1.text = Steam.getFriendPersonaName(id1)
	var id2 = Steam.getLobbyMemberByIndex(Multiplayer.lobby_id, 1)
	username2.text = Steam.getFriendPersonaName(id2)
	
	Multiplayer.host_ready_changed.connect(_on_host_ready_changed)
	Multiplayer.client_ready_changed.connect(_on_client_ready_changed)
	Multiplayer.both_players_ready.connect(_on_both_players_ready)
	

func _on_ready_button_pressed():
	print("pressed")
	$Click.play()
	await $Click.finished
	Multiplayer.set_ready.rpc(multiplayer.get_unique_id())
	ready_button.visible = false


func _on_host_ready_changed():
	print("Host is ready!")
	button1.visible = true
	player1.play("press")
	
func _on_client_ready_changed():
	print("Client is ready!")
	button2.visible = true
	player2.play("press")

func _on_both_players_ready():
	countdown_label.visible = true

	for text in ["3", "2", "1"]:
		countdown_label.text = text
		countdown_label.scale = Vector2(2, 2)
		countdown_label.modulate.a = 1.0

		var tween = create_tween()
		tween.tween_property(countdown_label, "scale", Vector2.ONE, 0.8)
		tween.parallel().tween_property(countdown_label, "modulate:a", 0.0, 0.8)

		await tween.finished

	countdown_label.visible = false
	queue_free()
