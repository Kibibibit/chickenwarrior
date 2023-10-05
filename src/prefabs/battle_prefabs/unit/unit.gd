@icon("res://assets/icons/unit.png")
@tool
extends Sprite2D
class_name Unit

const TEAM_PLAYER: int = 0
const TEAM_ENEMY: int = 1
const TEAM_ALLY: int = 2

@export var character: Character: set = _set_character
@export_enum("Player", "Enemy", "Ally") var team: int
@export var tile: Vector2i: set = _set_tile
@export var inventory: Array[Item]
@export var hp: int = 0

func _set_character(p_character: Character) -> void:
	character = p_character
	hp = character.hp

func _set_tile(p_tile: Vector2i):
	tile = p_tile
	position = tile*Map.TILE_SIZE
