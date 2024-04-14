class_name SummonData
extends Resource

@export_group("UI")
@export var icon: Texture
@export var name: String
@export var description: String # Optional tooltip
@export var model: PackedScene


@export_group("Game Effects")
@export var summoning_range: int
@export var lifespan: int
@export var effect_range: int
