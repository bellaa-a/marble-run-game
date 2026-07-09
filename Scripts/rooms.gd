extends Node


func _ready() -> void:
	Multiplayer.lobby_ready.connect(_on_lobby_ready)
	Multiplayer.join_status.connect(_on_join_status)
	Multiplayer.join_failed.connect(_on_join_failed)


func _on_lobby_ready():

	transition.fade_to_scene("res://Scenes/connected.tscn")


func _on_host_pressed():
	$Click.play()
	await $Click.finished
	Multiplayer.host_game()
	transition.fade_to_scene("res://Scenes/host_game.tscn")


func _on_join_pressed():
	$Click.play()
	await $Click.finished
	
	var code = $LobbyIDInput.text.to_upper().strip_edges()

	if code.length() != 6:
		$Error.text = "Invalid code format"
		return
	Multiplayer.join_game(code)


func _on_join_status(message):
	$Confirm.text = message


func _on_join_failed(message):
	$Error.text = message
	
