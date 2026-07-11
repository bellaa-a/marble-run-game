extends Control

enum StressType {
	COLD,
	HOT,
	CREEP
}

@onready var cold = $Cold
@onready var hot = $Hot
@onready var creep = $Creep

var stress_type


func _ready():
	randomize()

	cold.visible = false
	hot.visible = false
	creep.visible = false

	stress_type = [
		StressType.COLD,
		StressType.HOT,
		StressType.CREEP
	].pick_random()

	start_stress()


func start_stress():
	match stress_type:
		StressType.COLD:
			cold.visible = true
			print("cold")
			
		StressType.HOT:
			hot.visible = true
			print("hot")
			
		StressType.CREEP:
			creep.visible = true
			print("creep")
