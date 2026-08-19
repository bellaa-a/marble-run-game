extends Node2D


@export var group_name : String
@export var scene_type: Enum.SceneType
#@onready var area2d = $OpenGoal/DragArea


#func break_ice():
	#if is_broken:
		#return
#
	#is_broken = true
#
	#$OriginalIce.visible = false
	#$BreakingIce.visible = true
#
	#$BreakingIce/IceSound.play()
	#$BreakingIce.play("break")
	#
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#
	#for shape in find_children("*", "CollisionShape2D", true, false):
		#shape.set_deferred("disabled", true)
#
	#
	#await $BreakingIce.animation_finished
		#
	#for node in find_children("*", "CanvasItem", true, false):
		#node.visible = false
		#if node.is_in_group("goo"):
			#node.set_physics_process(false)
			#node.get_node("Area2D").monitoring = false
		#
	#$BreakingIce.visible = false
	#
	#Multiplayer.unlock_achievement("BREAK_ICE")
	#
	#
#func reset_ice():
	#is_broken = false
	#
	#for shape in find_children("*", "CollisionShape2D", true, false):
		#shape.set_deferred("disabled", false)
		#
	#for node in original_visibility:
		#node.visible = original_visibility[node]
		#
	#var pressed = find_children("GoalButtonPressed", "CanvasItem", true, false)
	#for p in pressed:
		#p.visible = false
#
	#$OriginalIce.visible = true
	#$BreakingIce.visible = false
#
	#$CollisionShape2D.disabled = false
	#$Area2D/CollisionShape2D.disabled = false
#
	#$BreakingIce.stop()
