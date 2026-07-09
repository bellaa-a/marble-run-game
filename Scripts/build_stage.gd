extends Node2D

@onready var effect_layer = $EffectLayer

func _ready():
	Multiplayer.build_stage = self
	$Pipe.position = Multiplayer.pipe_position
	$MultiplayerGoal.position = Multiplayer.goal_position
