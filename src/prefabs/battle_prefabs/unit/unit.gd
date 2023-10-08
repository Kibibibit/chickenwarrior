@icon("res://assets/icons/unit.png")
@tool
extends Sprite2D
class_name Unit

const TEAM_PLAYER: int = 0
const TEAM_ENEMY: int = 1
const TEAM_ALLY: int = 2

const UNIT_MOVE_SPEED: int = 500

@export var character: Character: set = _set_character
@export_enum("Player", "Enemy", "Ally") var team: int: set = _set_team
@export var tile: Vector2i: set = _set_tile
@export var inventory: Array[Item]
@export var hp: int = 0

var _path: Array[Vector2i] = []

func _set_character(p_character: Character) -> void:
	character = p_character
	if (Engine.is_editor_hint() and p_character != null):
		hp = character.hp

func _set_tile(p_tile: Vector2i):
	tile = p_tile
	if (Engine.is_editor_hint()):
		position = tile*Map.TILE_SIZE

func _set_team(p_team: int) -> void:
	team = p_team
	material.set_shader_parameter("player", p_team)

func _ready() -> void:
	material = preload("res://resources/materials/unit_shader/unit_shader_material.tres").duplicate()
	material.set_shader_parameter("player", team)

func get_unit_type() -> StringName:
	return UnitTypes.INFANTRY

func can_use(_item: Item) -> bool:
	return true

func path_to(path: Array[Vector2i]) -> void:
	_path = path

func _process(delta) -> void:
	if (not _path.is_empty()):
		if position == Vector2(_path[0]*Map.TILE_SIZE):
			_path.remove_at(0)
		if (not _path.is_empty()):
			var next_pos = _path[0]*Map.TILE_SIZE
			position.x = move_toward(position.x, next_pos.x, delta*UNIT_MOVE_SPEED)
			position.y = move_toward(position.y, next_pos.y, delta*UNIT_MOVE_SPEED)
		
