class_name DraftCard
extends Resource

@export var id: String
@export var type: Enum.CardType
@export var stage: Enum.Stage
@export var description : String
@export var icon : Texture2D
@export var icon_size: Vector2
@export var scene : PackedScene
@export var preview_scene : PackedScene
@export var block_scale: Vector2 = Vector2(1.0, 1.0)
