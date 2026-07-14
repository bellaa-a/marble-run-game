extends AnimatableBody2D

var can_rotate : bool = true
@export var side : String = "left"
@export var attack := false
@export var attack_number := 0

func _ready():
	add_to_group("rubber_band")


func _on_band_up_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
	if not _marble_can_interact_with_this_block(body):
		return
	$OriginalBand.visible = false
	$HitBandUp.visible = true
	$BandSound.play()
	$HitBandUp.play("HitUp")
	await $HitBandUp.animation_finished
	$HitBandUp.visible = false
	$OriginalBand.visible = true


func _on_band_down_body_entered(body: Node2D) -> void:
	if not body.is_in_group("marble"):
		return
	if not _marble_can_interact_with_this_block(body):
		return
	$OriginalBand.visible = false
	$HitBandDown.visible = true
	$BandSound.play()
	$HitBandDown.play("HitDown")
	await $HitBandDown.animation_finished
	$HitBandDown.visible = false
	$OriginalBand.visible = true


func _marble_can_interact_with_this_block(marble) -> bool:
	if attack:
		return marble.attack and marble.attack_number <= get_tree().current_scene.active_attack_count()

	return not marble.attack
