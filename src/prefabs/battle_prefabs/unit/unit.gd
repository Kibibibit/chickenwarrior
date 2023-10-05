@icon("res://assets/icons/unit.png")
@tool
extends Sprite2D
class_name Unit


@export var character: Character
@export_enum("Player", "Enemy", "Ally") var team: int
@export var tile: Vector2i: set = _set_tile
@export var inventory: Array[Item]
@export var hp: int = -1

func _ready() -> void:
	hp = character.hp


func _set_tile(p_tile: Vector2i):
	tile = p_tile
	position = tile*16
