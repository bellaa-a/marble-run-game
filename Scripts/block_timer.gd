extends Node2D

@export var timer_rule := "4'-8'"

func _ready():
	$Label.text = timer_rule


func can_use() -> bool:
	var rule = $Label.text.strip_edges()

	if rule.begins_with("!"):
		return not _check_rule(rule.trim_prefix("!"))

	return _check_rule(rule)


func _check_rule(rule: String) -> bool:
	var t = GameState.time

	# >3'
	if rule.begins_with(">"):
		return t >= float(rule.trim_prefix(">").replace("'", ""))

	# <5'
	if rule.begins_with("<"):
		return t <= float(rule.trim_prefix("<").replace("'", ""))

	# 4'-8'
	if "-" in rule:
		var parts = rule.split("-")
		var start = float(parts[0].replace("'", ""))
		var end = float(parts[1].replace("'", ""))
		return t >= start and t <= end

	# 6.*'
	if ".*" in rule:
		var sec = int(rule.replace(".*'", ""))
		return int(t) == sec

	return true
