extends Control

var powerup_sender_id: int
var marbles := []
var original_scales := {}


func _ready() -> void:
	marbles = get_tree().get_nodes_in_group("marble")

	for marble in marbles:
		var original = marble.get_node("OriginalMarble")
		original_scales[marble] = original.scale

	await poof_disappear()

	await get_tree().create_timer(20.0).timeout

	await poof_reappear()

	Multiplayer.powerup_finished.rpc_id(powerup_sender_id)
	queue_free()


func poof_disappear() -> void:
	$Poof.play()
	var tween = create_tween()

	for marble in marbles:
		var original = marble.get_node("OriginalMarble")
		var original_scale: Vector2 = original_scales[marble]

		original.visible = true
		original.modulate.a = 1.0
		original.scale = original_scale

		tween.parallel().tween_property(
			original,
			"scale",
			original_scale * 1.5,
			0.15
		)

		tween.parallel().tween_property(
			original,
			"modulate:a",
			0.0,
			0.15
		)

	await tween.finished

	for marble in marbles:
		marble.get_node("OriginalMarble").visible = false


func poof_reappear() -> void:
	$Poof.play()

	var tween = create_tween()

	for marble in marbles:
		var original = marble.get_node("OriginalMarble")
		var original_scale: Vector2 = original_scales[marble]

		original.visible = true
		original.modulate.a = 0.0
		original.scale = original_scale * 1.5

		tween.parallel().tween_property(
			original,
			"scale",
			original_scale,
			0.2
		)

		tween.parallel().tween_property(
			original,
			"modulate:a",
			1.0,
			0.2
		)

	await tween.finished
