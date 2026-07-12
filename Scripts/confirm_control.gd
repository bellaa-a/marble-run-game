extends Control


signal confirmed
signal cancelled

func _on_yes_pressed() -> void:
	confirmed.emit()


func _on_no_pressed() -> void:
	cancelled.emit()
