extends Node2D


func _ready():
	$Connected.play()
	var id1 = Steam.getLobbyMemberByIndex(Multiplayer.lobby_id, 0)
	$Username1.text = Steam.getFriendPersonaName(id1)
	var id2 = Steam.getLobbyMemberByIndex(Multiplayer.lobby_id, 1)
	$Username2.text = Steam.getFriendPersonaName(id2)
	
	await get_tree().create_timer(4).timeout
	transition.fade_to_scene("res://Scenes/draft_stage.tscn")
		
