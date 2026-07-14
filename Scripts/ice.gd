extends AnimatableBody2D

var can_rotate : bool = true
@export var break_force_threshold: float = 450.0
@export var side : String = "left"
@export var attack := false
@export var attack_number := 0

var is_broken = false
var original_visibility := {}

func _ready():
	add_to_group("ice")
	
	for node in find_children("*", "CanvasItem", true, false):
		original_visibility[node] = node.visible


func _marble_can_interact_with_this_block(marble) -> bool:
	if attack:
		return marble.attack and marble.attack_number <= get_tree().current_scene.active_attack_count()

	return not marble.attack
	
func break_ice():
	if is_broken:
		return

	is_broken = true

	$OriginalIce.visible = false
	$BreakingIce.visible = true

	$BreakingIce/IceSound.play()
	$BreakingIce.play("break")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	for shape in find_children("*", "CollisionShape2D", true, false):
		shape.set_deferred("disabled", true)
	
	await $BreakingIce.animation_finished
	
	for node in find_children("*", "CanvasItem", true, false):
		node.visible = false
		if node.is_in_group("goo"):
			node.set_physics_process(false)
			node.get_node("Area2D").monitoring = false
		
	$BreakingIce.visible = false
	
	
func reset_ice():
	is_broken = false
	
	for shape in find_children("*", "CollisionShape2D", true, false):
		shape.set_deferred("disabled", false)
		
	for node in original_visibility:
		node.visible = original_visibility[node]
		
	var pressed = find_children("GoalButtonPressed", "CanvasItem", true, false)
	for p in pressed:
		p.visible = false

	$OriginalIce.visible = true
	$BreakingIce.visible = false

	$CollisionShape2D.disabled = false
	$Area2D/CollisionShape2D.disabled = false

	$BreakingIce.stop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_broken:
		return

	if not body.is_in_group("marble"):
		return
		
	if not _marble_can_interact_with_this_block(body):
		return

	var speed_before = body.previous_velocity.length()
	print(speed_before)
	
	if speed_before >= break_force_threshold:
		break_ice()
