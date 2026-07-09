extends Node2D

func _process(_delta):
	var icon := "▸"
	if not GameState.locked:
		icon = "⏸"

	$Label.text = "%s %0.2fs" % [icon, GameState.time]
