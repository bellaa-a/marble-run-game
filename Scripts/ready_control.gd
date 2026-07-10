extends Control


@onready var username1 = $Username1
@onready var username2 = $Username2
@onready var ready_button = $ReadyButton
@onready var player1 = $Player1
@onready var player2 = $Player2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Multiplayer.reset_ready()
	var id1 = Steam.getLobbyMemberByIndex(Multiplayer.lobby_id, 0)
	username1.text = Steam.getFriendPersonaName(id1)
	var id2 = Steam.getLobbyMemberByIndex(Multiplayer.lobby_id, 1)
	username2.text = Steam.getFriendPersonaName(id2)
	
	Multiplayer.host_ready_changed.connect(_on_host_ready_changed)
	Multiplayer.client_ready_changed.connect(_on_client_ready_changed)


func _on_ready_button_pressed():
	print("pressed")
	Multiplayer.set_ready.rpc(multiplayer.get_unique_id())
	ready_button.disabled = true


func _on_host_ready_changed():
	print("Host is ready!")
	player1.play("press")

func _on_client_ready_changed():
	print("Client is ready!")
	player2.play("press")
