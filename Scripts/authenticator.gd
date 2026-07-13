extends LineEdit

var digits: Array
var previous: LineEdit
var next: LineEdit

func _ready():
	digits = get_parent().get_children()

	var index = digits.find(self)

	if index > 0:
		previous = digits[index - 1]

	if index < digits.size() - 1:
		next = digits[index + 1]

	text_changed.connect(_on_text_changed)


func _gui_input(event):
	if event is InputEventKey \
	and event.pressed \
	and event.keycode == KEY_BACKSPACE:

		if text.length() == 1:
			clear()

			if previous:
				previous.grab_focus()

			accept_event()

		elif text.is_empty():
			if previous:
				previous.grab_focus()

			accept_event()


func _on_text_changed(new_text: String):
	if new_text.length() == 1:
		if next:
			next.grab_focus()

	elif new_text.length() > 1:
		# User pasted a code
		for i in range(min(new_text.length(), digits.size())):
			digits[i].text = new_text.substr(i, 1)

		# Focus the next empty box (or the last one if full)
		var last = min(new_text.length(), digits.size()) - 1
		if last >= 0:
			digits[last].grab_focus()
