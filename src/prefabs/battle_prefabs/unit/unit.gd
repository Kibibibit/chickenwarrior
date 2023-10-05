@icon("res://assets/icons/unit.png")
@tool
extends Sprite2D
class_name Unit


@export var character: Character
@export_enum("Player", "Enemy", "Ally") var team: int
@export var tile: Vector2i: set = _set_tile
@export var inventory: Array[Item]


func _set_tile(p_tile: Vector2i):
	tile = p_tile
	position = tile*16
