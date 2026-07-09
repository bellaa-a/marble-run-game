extends Node


var pipe_position: Vector2
var goal_position: Vector2

var peer: SteamMultiplayerPeer

var is_host := false

signal lobby_ready
signal join_status(message)
signal join_failed(message)

var lobby_id := 0
var lobby_code := ""
var game_started := false
var player_inventory: Array[Dictionary] = []

var build_stage: Node = null
var rooms: Node = null

const CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


func _ready():

	var init = Steam.steamInit()

	print("Steam init:", init)

	if not init:
		print("Steam failed to initialize")
		return

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)

	randomize()

	await get_tree().create_timer(1.0).timeout

	print("Steam ID:", Steam.getSteamID())


func setup_multiplayer_signals():

	var mp = get_tree().get_multiplayer()

	if not mp.peer_connected.is_connected(_on_peer_connected):
		mp.peer_connected.connect(_on_peer_connected)

	if not mp.connected_to_server.is_connected(_on_connected_to_server):
		mp.connected_to_server.connect(_on_connected_to_server)

	if not mp.server_disconnected.is_connected(_on_server_disconnected):
		mp.server_disconnected.connect(_on_server_disconnected)
		
func _on_connected_to_server():

	print("Connected to Steam multiplayer server!")

	lobby_ready.emit()


func _on_peer_connected(id):

	print("Opponent connected! Peer ID:", id)

	if multiplayer.is_server() and not game_started:

		game_started = true

		print("Starting game setup")
		randomize_layout()

		lobby_ready.emit()


func _on_server_disconnected():

	print("Server disconnected")

func _process(_delta):

	Steam.run_callbacks()


# -------------------------
# Multiplayer Layout
# -------------------------

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

	sync_layout.rpc(
		pipe_position,
		goal_position
	)


var layout_received := false


@rpc("authority", "call_local", "reliable")
func sync_layout(
	pipe_pos: Vector2,
	goal_pos: Vector2
):

	pipe_position = pipe_pos
	goal_position = goal_pos

	print(
		"Received layout:",
		pipe_position,
		goal_position
	)


	if not layout_received:
		layout_received = true
		lobby_ready.emit()


# -------------------------
# Card Sync
# -------------------------

@rpc("any_peer", "call_remote", "reliable")
func send_discarded_cards(cards: Array[String]):

	print(
		"Received opponent discarded cards:",
		cards
	)

	get_tree().call_group(
		"draft",
		"receive_opponent_cards",
		cards
	)


# -------------------------
# Hosting
# -------------------------

func host_game():

	if lobby_id != 0:
		print("Already in lobby")
		return

	is_host = true

	print("Creating lobby...")

	Steam.createLobby(
		Steam.LOBBY_TYPE_PUBLIC,
		2
	)


func _on_lobby_created(
	success: bool,
	new_lobby_id: int
):

	if not success:

		print("Failed to create lobby")
		return


	lobby_id = new_lobby_id

	lobby_code = generate_lobby_code()

	Steam.setLobbyData(
		lobby_id,
		"code",
		lobby_code
	)

	print("Lobby created:", lobby_id)
	print("Room Code:", lobby_code)


	await get_tree().create_timer(0.5).timeout


	peer = SteamMultiplayerPeer.new()

	var result = peer.create_host()

	print("Host result:", result)


	if result == OK:

		multiplayer.multiplayer_peer = peer
		setup_multiplayer_signals()

		print("Steam host started")
		print(
			"My peer ID:",
			multiplayer.get_unique_id()
		)

	else:

		print("Failed to start Steam host")


# -------------------------
# Joining
# -------------------------

func join_game(code: String):

	if lobby_id != 0:
		print("Already in lobby")
		return


	print("Searching for room:", code)


	Steam.addRequestLobbyListStringFilter(
		"code",
		code,
		Steam.LOBBY_COMPARISON_EQUAL
	)


	Steam.requestLobbyList()



func _on_lobby_match_list(
	lobbies: Array
):

	print(
		"Found rooms:",
		lobbies.size()
	)

	if lobbies.size() == 0:

		join_failed.emit("Invalid room code")
		return

	var found_lobby = lobbies[0]

	var members = Steam.getNumLobbyMembers(
		found_lobby
	)

	if members >= 2:

		join_failed.emit("Room is full")
		return

	print(
		"Joining lobby:",
		found_lobby
	)
	join_status.emit("Joining room...")

	Steam.joinLobby(
		found_lobby
	)


func _on_lobby_joined(
	new_lobby_id,
	_permissions,
	_locked,
	_response
):

	# Host receives this callback too sometimes
	if is_host:
		return


	lobby_id = new_lobby_id


	print("Joined lobby!")
	print("Lobby ID:", lobby_id)


	lobby_code = Steam.getLobbyData(
		lobby_id,
		"code"
	)


	print("Room Code:", lobby_code)


	peer = SteamMultiplayerPeer.new()

	var owner_id = Steam.getLobbyOwner(lobby_id)

	print("Lobby owner Steam ID:", owner_id)


	var result = peer.create_client(owner_id)

	print("Client result:", result)


	if result == OK:

		multiplayer.multiplayer_peer = peer

		print("Steam client started")

		print(
			"My peer ID:",
			multiplayer.get_unique_id()
		)


	else:

		print("Failed to start Steam client")


# -------------------------
# Lobby State
# -------------------------

func _on_lobby_chat_update(
	_lobby_id,
	_changed_id,
	_making_change_id,
	_state
):

	check_lobby_ready()


func check_lobby_ready():

	if lobby_id == 0:
		return


	var members = Steam.getNumLobbyMembers(lobby_id)

	print("Players in lobby:", members)


	if members == 2:

		print("Steam lobby ready!")

# -------------------------
# Utilities
# -------------------------

func generate_lobby_code() -> String:

	var code := ""


	for i in range(6):

		code += CODE_CHARS[
			randi() % CODE_CHARS.length()
		]


	return code



func leave_lobby():

	if peer:

		peer.close()


	if lobby_id != 0:

		Steam.leaveLobby(
			lobby_id
		)


	print("Left lobby")


	lobby_id = 0
	lobby_code = ""



func _notification(what):

	if what == NOTIFICATION_WM_CLOSE_REQUEST:

		leave_lobby()

		get_tree().quit()


func reset_match():
	player_inventory.clear()


func send_powerup(card_id: String):
	var opponent_id = get_opponent_id()
	if opponent_id == -1:
		return
	use_powerup.rpc_id(opponent_id, card_id)
	

@rpc("any_peer")
func use_powerup(card_id: String):
	var card = CardDatabase.get_card_by_id(card_id)
	var effect = card.effect_scene.instantiate()
	build_stage.effect_layer.add_child(effect)
	effect.activate()


func get_opponent_id() -> int:
	for id in multiplayer.get_peers():
		return id
	
	return -1
