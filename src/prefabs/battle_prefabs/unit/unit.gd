@icon("res://assets/icons/unit.png")
@tool
extends Sprite2D
class_name Unit

const ACTION_NONE: int = -1
const ACTION_ARMS: int = 0
const ACTION_ATTACK: int = 1
const ACTION_ASSIST: int = 2
const ACTION_ITEMS: int = 9
const ACTION_WAIT: int = 10

const ACTION_MAP: Dictionary = {
	ACTION_ARMS: "Arms",
	ACTION_ATTACK:"Attack",
	ACTION_ASSIST:"Assist",
	ACTION_ITEMS:"Items",
	ACTION_WAIT:"Wait"
}


const TEAM_PLAYER: int = 0
const TEAM_ENEMY: int = 1
const TEAM_ALLY: int = 2

const UNIT_MOVE_SPEED: int = 500

signal move_finished

@export var character: Character: set = _set_character
@export_enum("Player", "Enemy", "Ally") var team: int: set = _set_team
@export var tile: Vector2i: set = _set_tile
@export var inventory: Array[Item]
@export var hp: int = 0
var moved: bool = false : set = _set_moved

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

func _set_moved(p_moved: bool) -> void:
	moved = p_moved
	material.set_shader_parameter("moved", p_moved)

func _ready() -> void:
	material = preload("res://resources/materials/unit_shader/unit_shader_material.tres").duplicate()
	material.set_shader_parameter("player", team)

func get_unit_type() -> int:
	return character.get_unit_type()

func can_use(_item: Item) -> bool:
	return true

func path_to(path: Array[Vector2i]) -> void:
	_path = path.duplicate()

func get_valid_actions(new_tile: Vector2i, attack_tiles: Array[Vector2i], unit_positions: Dictionary) -> Array[int]:
	var out: Array[int] = []
	if (_can_use_arms()):
		out.append(ACTION_ARMS)
	if (_can_attack(new_tile, attack_tiles, unit_positions)):
		out.append(ACTION_ATTACK)
	if (_can_assist()):
		out.append(ACTION_ASSIST)
	
	if (not inventory.is_empty()):
		out.append(ACTION_ITEMS)
	
	out.append(ACTION_WAIT)
	out.sort()
	return out


func get_weapon_ranges() -> Vector2i:
	var min_range:int = -1
	var max_range:int = -1
	for item in inventory:
		if (item is Weapon and can_use(item)):
			if (item.min_range < min_range or min_range == -1):
				min_range = item.min_range
			if (item.max_range > max_range or max_range == -1):
				max_range = item.max_range
	return Vector2i(min_range, max_range)

func _can_use_arms() -> bool:
	return false

func _can_attack(new_tile: Vector2i, attack_tiles: Array[Vector2i], unit_positions: Dictionary) -> bool:
	var ranges = get_weapon_ranges()
	var min_range = ranges.x
	var max_range = ranges.y
	for attack_tile in attack_tiles:
		var dist = VectorUtils.manhattan_distance(new_tile, attack_tile)
		if (attack_tile in unit_positions):
			if (min_range <= dist and dist <= max_range):
				var unit: Unit = instance_from_id(unit_positions[attack_tile])
				if (unit.team != team):
					return true
	return false
	
func _can_assist() -> bool:
	return false

func _process(delta) -> void:
	if (not _path.is_empty()):
		if position == Vector2(_path[0]*Map.TILE_SIZE):
			_path.remove_at(0)
		if (not _path.is_empty()):
			var next_pos = _path[0]*Map.TILE_SIZE
			position.x = move_toward(position.x, next_pos.x, delta*UNIT_MOVE_SPEED)
			position.y = move_toward(position.y, next_pos.y, delta*UNIT_MOVE_SPEED)
		else:
			move_finished.emit()

static func get_action_label(action_code: int) -> String:
	if (action_code in ACTION_MAP):
		return ACTION_MAP[action_code]
	else:
		return "???"
