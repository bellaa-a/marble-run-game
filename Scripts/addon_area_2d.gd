extends Area2D

const SNAP_DISTANCE := 40.0

var dragging := false
var current_snap = null
var original_parent
var original_global_position
var attached_snap = null

func _ready() -> void:
	show_snap_points(false)
	update_closest_snap()


func _input_event(_viewport, event, _shape_idx):
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		print("Addon clicked")
		Multiplayer.dragging_addon = true

		dragging = true

		if attached_snap:
			attached_snap.occupant = null
			attached_snap.set_highlight(false)
			attached_snap = null

		var addon = get_parent()

		# remove from block so rotation does not affect it
		addon.reparent(get_tree().current_scene, true)

		original_global_position = addon.global_position

		show_snap_points(true)

func _process(_delta):

	if dragging:

		get_parent().global_position = get_global_mouse_position()

		update_closest_snap()


func _input(event):

	if !dragging:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and !event.pressed:
		dragging = false

		place_addon()


func show_snap_points(show_points: bool):

	for snap in get_tree().get_nodes_in_group("snap_points"):
		snap.visible = show_points
		snap.set_highlight(false)


func update_closest_snap():

	if current_snap:
		current_snap.set_highlight(false)

	current_snap = null

	var closest_distance := INF

	for snap in get_tree().get_nodes_in_group("snap_points"):

		if snap.is_occupied():
			continue

		var d = get_parent().global_position.distance_to(snap.global_position)

		if d < closest_distance:
			closest_distance = d
			current_snap = snap

	if current_snap and closest_distance < SNAP_DISTANCE:
		current_snap.set_highlight(true)
	else:
		current_snap = null


func place_addon():

	Multiplayer.dragging_addon = false

	show_snap_points(false)

	var addon = get_parent()
	var inventory_index = addon.get_meta("inventory_index")
	var inventory = Multiplayer.build_stage.inventory
	var found_card

	for card in inventory.hand_cards:
		if card.inventory_index == inventory_index:
			found_card = card
			break

	if current_snap == null:
		found_card.reset_card()
		Multiplayer.player_inventory[inventory_index]["used"] = false
		addon.queue_free()
		return

	var block = current_snap.get_block()

	var addon_holder = block.get_node("AddOns")

	addon.reparent(addon_holder)

	addon.position = current_snap.position - Vector2(0, 2)
	addon.rotation = current_snap.rotation


	var block_id = block.get_meta("block_id")
	var addon_id = addon.get_meta("addon_id")

	current_snap.occupant = addon
	attached_snap = current_snap
	
	Multiplayer.sync_addon.rpc(
		addon_id,
		addon.get_meta("card_id"),
		block_id,
		addon.position,
		addon.rotation
	)
	current_snap = null
	found_card.use_card()
	Multiplayer.player_inventory[inventory_index]["used"] = true


func start_drag():
	Multiplayer.dragging_addon = true
	dragging = true

	show_snap_points(true)
