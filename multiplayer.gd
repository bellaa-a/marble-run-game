extends Node

var pipe_position: Vector2
var goal_position: Vector2

signal lobby_ready
var lobby_id := 0
var lobby_code := ""
var join_error := ""

const CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


func _ready():

	Steam.steamInit()

	await get_tree().create_timer(1.0).timeout

	print("Steam ID: ", Steam.getSteamID())


	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)


func randomize_layout():
	pipe_position = Vector2(
		randf_range(-250, 250),
		-220
	)
	
	goal_position = Vector2(
		randf_range(-300, 300),
		170
	)

	print("Generated layout:", pipe_position, goal_position)

	sync_layout.rpc(pipe_position, goal_position)


@rpc("authority", "call_remote")
func sync_layout(pipe_pos: Vector2, goal_pos: Vector2):
	pipe_position = pipe_pos
	goal_position = goal_pos
	print("Received layout:", pipe_position, goal_position)
	
	
func _process(_delta):

	Steam.run_callbacks()


@rpc("any_peer", "call_remote")
func send_discarded_cards(cards: Array[String]):
	print("Received opponent discarded cards:", cards)

	# Tell the draft scene
	get_tree().call_group(
		"draft",
		"receive_opponent_cards",
		cards
	)
	

func host_game():

	print("Creating lobby...")

	# Must be PUBLIC so Steam can search it
	Steam.createLobby(
		Steam.LOBBY_TYPE_PUBLIC,
		2
	)



func _on_lobby_created(success: bool, new_lobby_id: int):

	print("Lobby callback received")


	if success:

		lobby_id = new_lobby_id

		lobby_code = generate_lobby_code()


		# Save code to Steam lobby data
		Steam.setLobbyData(
			lobby_id,
			"code",
			lobby_code
		)


		print("Lobby created!")
		print("Lobby ID:", lobby_id)
		print("Room Code:", lobby_code)


	else:

		print("Failed to create lobby")


func generate_lobby_code() -> String:

	var code := ""


	for i in range(6):

		code += CODE_CHARS[
			randi() % CODE_CHARS.length()
		]


	return code


func join_game(code: String):

	print("Searching for room:", code)


	Steam.addRequestLobbyListStringFilter(
		"code",
		code,
		Steam.LOBBY_COMPARISON_EQUAL
	)


	Steam.requestLobbyList()



func _on_lobby_match_list(lobbies: Array):

	print("Found rooms:", lobbies.size())


	# No room found
	if lobbies.size() == 0:

		join_error = "Invalid room code"
		return

	var found_lobby = lobbies[0]

	var members = Steam.getNumLobbyMembers(
		found_lobby
	)

	# Already full
	if members >= 2:

		join_error = "Room is full"
		return

	print("Joining lobby:", found_lobby)

	Steam.joinLobby(found_lobby)


func _on_lobby_joined(
	new_lobby_id,
	_permissions,
	_locked,
	_response
):

	lobby_id = new_lobby_id

	print("Joined lobby!")
	print("Lobby ID:", lobby_id)

	lobby_code = Steam.getLobbyData(lobby_id, "code")

	print("Room Code:", lobby_code)

	check_lobby_ready()


func _on_lobby_chat_update(
	_lobby_id,
	_changed_id,
	_making_change_id,
	_state
):

	check_lobby_ready()


func leave_lobby():

	if lobby_id != 0:

		Steam.leaveLobby(
			lobby_id
		)


		print("Left lobby")


		lobby_id = 0
		lobby_code = ""


func check_lobby_ready():

	if lobby_id == 0:
		return

	var members = Steam.getNumLobbyMembers(lobby_id)

	print("Players in lobby:", members)

	if members == 2:
		print("Lobby is ready!")

		if multiplayer.is_server():
			randomize_layout()

		lobby_ready.emit()
		

func _notification(what):

	if what == NOTIFICATION_WM_CLOSE_REQUEST:

		leave_lobby()

		get_tree().quit()
