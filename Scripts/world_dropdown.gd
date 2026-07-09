extends OptionButton

func _ready() -> void:
	var popup := get_popup()

	for i in popup.item_count:
		popup.set_item_as_checkable(i, false)

var world_paths := [
	"res://Scenes/group1.tscn",
	"res://Scenes/group2.tscn",
	"res://Scenes/group3.tscn",
	"res://Scenes/group4.tscn",
	"res://Scenes/group5.tscn",
	"res://Scenes/group6.tscn",
	"res://Scenes/group7.tscn",
	"res://Scenes/group8.tscn",
	"res://Scenes/group9.tscn",
	"res://Scenes/group10.tscn",
]

func _on_item_selected(index: int) -> void:
	transition.fade_to_scene(world_paths[index])
	select(-1)
