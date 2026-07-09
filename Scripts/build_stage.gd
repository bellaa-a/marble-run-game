extends Node2D

@onready var effect_layer = $EffectLayer

func _ready():
	Multiplayer.build_stage = self
