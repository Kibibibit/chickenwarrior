extends Node2D
class_name BattleScene

const STATE_NO_CONTROL: int = 0
const STATE_PLAYER_TURN: int = 1
const STATE_ENEMY_TURN: int = 2
const STATE_PLAYER_UNIT_SELECTED: int = 3
const STATE_ENEMY_UNIT_SELECTED: int = 4
const STATE_MENU_OPEN: int = 5


var battle_state: int = STATE_PLAYER_TURN
var map: Map : set = set_map
var units: Dictionary = {}
var unit_positions: Dictionary = {}

@onready
var camera: Camera2D = $Camera2D
@onready
var cursor: Cursor = $Cursor
@onready
var ui: BattleUI = $BattleUI
@onready
var tile_highlight: TileHighlight = $TileHighlight


func set_map(p_map: Map):
	assert(map == null, "Tried to reset map!")
	map = p_map

func _ready() -> void:
	assert(map != null, "Tried to instantiate battle without map!")
	add_child(map)
	
	cursor.map_rect = map.map_rect()
	cursor.cursor_moved.connect(_cursor_moved)
	cursor.cursor_action.connect(_cursor_action)
	cursor.can_move = true
	camera.position = Vector2(map.map_rect().position) + map.map_rect().size*Map.TILE_SIZE*0.5
	
	tile_highlight.map = map
	
	for unit in map.get_units():
		units[unit.get_instance_id()] = unit
		unit_positions[unit.tile] = unit.get_instance_id()


func _unit_at(tile: Vector2i) -> Unit:
	if tile in unit_positions:
		return units[unit_positions[tile]]
	return null

func _cursor_action(action: int) -> void:
	match battle_state:
		STATE_PLAYER_TURN:
			_cursor_action_player_turn_state(action)
		_:
			return

func _cursor_moved(tile: Vector2i) -> void:
	match battle_state:
		STATE_PLAYER_TURN:
			_cursor_moved_player_turn_state(tile)
		_:
			return

func _cursor_action_player_turn_state(action: int) -> void:
	var unit: Unit = _unit_at(cursor.tile)
	if unit != null and action == Cursor.SELECT:
		tile_highlight.clear_highlight()
		var move_tiles = tile_highlight.get_move_tiles(unit)
		var attack_tiles = tile_highlight.get_attack_tiles(unit, move_tiles)
		tile_highlight.highlight_tiles(move_tiles, attack_tiles)
	if action == Cursor.DESELECT:
		tile_highlight.clear_highlight()

func _cursor_moved_player_turn_state(tile: Vector2i) -> void:
	ui.set_tile_type(map.get_tile_type(tile))
	ui.set_unit(_unit_at(tile))

