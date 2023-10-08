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

var selected_unit_id: int = Constants.NULL_ID
var unit_start_pos: Vector2i

var move_tiles: Array[Vector2i]
var attack_tiles: Array[Vector2i]

@onready
var camera: Camera2D = $Camera2D
@onready
var cursor: Cursor = $Cursor
@onready
var ui: BattleUI = $BattleUI
@onready
var tile_highlight: TileHighlight = $TileHighlight
@onready
var arrows: Arrows = $Arrows


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
	arrows.map = map
	
	
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
		STATE_PLAYER_UNIT_SELECTED:
			_cursor_action_player_unit_selected_state(action)
		STATE_ENEMY_UNIT_SELECTED:
			_cursor_action_enemy_unit_selected_state(action)
		_:
			return

func _cursor_moved(tile: Vector2i) -> void:
	ui.set_tile_type(map.get_tile_type(tile))
	match battle_state:
		STATE_PLAYER_TURN:
			_cursor_moved_player_turn_state(tile)
		STATE_PLAYER_UNIT_SELECTED:
			_cursor_moved_player_unit_selected_state(tile)
		_:
			return

func _select_unit(unit: Unit) -> void:
	tile_highlight.clear_highlight()
	move_tiles = tile_highlight.get_move_tiles(unit, unit_positions)
	attack_tiles = tile_highlight.get_attack_tiles(unit, move_tiles)
	tile_highlight.highlight_tiles(move_tiles, attack_tiles)
	selected_unit_id = unit.get_instance_id()

func _deselect_unit() -> void:
	selected_unit_id = Constants.NULL_ID
	tile_highlight.clear_highlight()
	battle_state = STATE_PLAYER_TURN
	arrows.clear_arrows()
	move_tiles = []
	attack_tiles = []

func _cursor_action_player_turn_state(action: int) -> void:
	var unit: Unit = _unit_at(cursor.tile)
	if unit != null and action == Cursor.SELECT:
		_select_unit(unit)
		if (unit.team == Teams.PLAYER):
			unit_start_pos = unit.tile
			battle_state = STATE_PLAYER_UNIT_SELECTED
			return
		else:
			battle_state = STATE_ENEMY_UNIT_SELECTED
			return

func _cursor_action_player_unit_selected_state(action: int) -> void:
	var unit: Unit = instance_from_id(selected_unit_id)
	if action == Cursor.DESELECT:
		unit.position = unit_start_pos*Map.TILE_SIZE
		_deselect_unit()
		return
	elif action == Cursor.SELECT:
		unit.position = unit_start_pos*Map.TILE_SIZE
		unit.path_to(arrows.path)
		
func _cursor_action_enemy_unit_selected_state(action: int) -> void:
	if (action == Cursor.DESELECT):
		_deselect_unit()
	elif (action == Cursor.SELECT):
		var new_unit: Unit = _unit_at(cursor.tile)
		if (new_unit != null):
			_select_unit(new_unit)
			if (new_unit.team == Teams.PLAYER):
				battle_state = STATE_PLAYER_UNIT_SELECTED
		else:
			_deselect_unit()
				

func _cursor_moved_player_turn_state(tile: Vector2i) -> void:
	ui.set_unit(_unit_at(tile))

func _cursor_moved_player_unit_selected_state(tile: Vector2i) -> void:
	var unit: Unit = instance_from_id(selected_unit_id)
	if (tile in move_tiles and tile != unit.tile):
		var passable_tiles: Array[Vector2i] = move_tiles
		for unit_tile in unit_positions.keys():
			if (_unit_at(unit_tile).team == unit.team):
				passable_tiles.append(unit_tile)
		if (_unit_at(tile) == null):
			arrows.draw_path(unit.tile, tile, unit.get_unit_type(), passable_tiles)
	elif (tile == unit.tile):
		arrows.clear_arrows()

