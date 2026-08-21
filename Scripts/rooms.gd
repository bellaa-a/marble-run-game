extends Node

func _ready() -> void:
	Multiplayer.lobby_ready.connect(_on_lobby_ready)
	Multiplayer.join_status.connect(_on_join_status)
	Multiplayer.join_failed.connect(_on_join_failed)

	# Every time Rooms is opened, default to 10 minutes
	Multiplayer.stage_one_time = 600.0


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
	$Error.text = ""
	$Confirm.text = message


func _on_join_failed(message):
	$Confirm.text = ""
	$Error.text = message


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			Multiplayer.stage_one_time = 600.0
		1:
			Multiplayer.stage_one_time = 300.0
		2:
			Multiplayer.stage_one_time = 60.0


func _on_lobby_id_input_text_submitted(_new_text: String) -> void:
	_on_join_pressed()


func _on_back_pressed() -> void:
	$Click.play()
	await $Click.finished
	transition.fade_to_scene("res://Scenes/start.tscn")
