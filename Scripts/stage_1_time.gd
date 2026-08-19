extends OptionButton

func _ready() -> void:
	var popup := get_popup()

	for i in popup.item_count:
		popup.set_item_as_checkable(i, false)
