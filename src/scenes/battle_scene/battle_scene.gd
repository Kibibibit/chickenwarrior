extends Node2D
class_name BattleScene

const STATE_NO_CONTROL: int = 0
const STATE_PLAYER_TURN: int = 1
const STATE_ENEMY_TURN: int = 2
const STATE_PLAYER_UNIT_SELECTED: int = 3
const STATE_PLAYER_UNIT_MOVED: int = 4
const STATE_ENEMY_UNIT_SELECTED: int = 5
const STATE_MENU_OPEN: int = 6
const STATE_PLAYER_ATTACK_SELECT: int = 7


var battle_state: int = STATE_PLAYER_TURN
var map: Map : set = set_map
var units: Dictionary = {}
var unit_positions: Dictionary = {}

var selected_unit_id: int = Constants.NULL_ID
var unit_start_pos: Vector2i
var cursor_start_pos: Vector2i

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
		unit.current_tile_type = map.get_tile_type(unit.tile)


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
		STATE_PLAYER_ATTACK_SELECT:
			_cursor_action_player_attack_select(action)
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

func _selected_unit() -> Unit:
	if (selected_unit_id != Constants.NULL_ID):
		return instance_from_id(selected_unit_id)
	return null

func _select_unit(unit: Unit) -> void:
	tile_highlight.clear_highlight()
	move_tiles = tile_highlight.get_move_tiles(unit, unit_positions)
	attack_tiles = tile_highlight.get_attack_tiles(unit, move_tiles)
	tile_highlight.highlight_tiles(move_tiles, attack_tiles)
	selected_unit_id = unit.get_instance_id()
	unit.move_finished.connect(_unit_move_finished.bind(unit))

func _deselect_unit(unit: Unit) -> void:
	selected_unit_id = Constants.NULL_ID
	tile_highlight.clear_highlight()
	battle_state = STATE_PLAYER_TURN
	arrows.clear_arrows()
	move_tiles = []
	attack_tiles = []
	unit.move_finished.disconnect(_unit_move_finished)

func _action_selected(action: int) -> void:
	var unit: Unit = _selected_unit()
	
	if (action == Unit.ACTION_WAIT):
		_move_unit(unit)
		cursor.can_move = true
		_deselect_unit(unit)
		battle_state = STATE_PLAYER_TURN
	elif (action == Unit.ACTION_ATTACK):
		_attack_action_selected(unit)

	else:
		if (action != Unit.ACTION_NONE):
			print("Unrecognised action %s (%s)" % [action, Unit.get_action_label(action)])
		cursor.can_move = true
		unit.position = unit_start_pos*Map.TILE_SIZE
		battle_state = STATE_PLAYER_UNIT_SELECTED

func _attack_action_selected(unit: Unit) -> void:
	cursor_start_pos = cursor.tile
	var weapon: Weapon = await ui.show_weapon_list(unit)
	if (weapon == null):
		_unit_move_finished(unit)
		return
	else:
		battle_state = STATE_PLAYER_ATTACK_SELECT
		tile_highlight.clear_highlight()
		attack_tiles = tile_highlight.get_attack_tiles_in_range(cursor.tile, weapon)
		tile_highlight.highlight_tiles([], attack_tiles)
		arrows.clear_arrows()
		cursor.allowed_tiles = attack_tiles.duplicate()

func _move_unit(unit: Unit) -> void:
	unit_positions.erase(unit.tile)
	unit.tile = cursor.tile
	unit_positions[cursor.tile] = unit.get_instance_id()
	unit.current_tile_type = map.get_tile_type(cursor.tile)
	unit.moved = true
		
func _cursor_action_player_turn_state(action: int) -> void:
	var unit: Unit = _unit_at(cursor.tile)
	if unit != null and action == Cursor.SELECT:
		if (not unit.moved):
			_select_unit(unit)
			if (unit.team == Teams.PLAYER):
				unit_start_pos = unit.tile
				battle_state = STATE_PLAYER_UNIT_SELECTED
				return
			else:
				battle_state = STATE_ENEMY_UNIT_SELECTED
				return
	elif unit != null and action == Cursor.DESELECT:
		# Display the stats menu
		unit.character.print_stats()
		for u in units.keys():
			if (u != unit.get_instance_id()):
				var other: Unit = units[u]
				print(unit.character.name," vs ",other.character.name)
				print(unit.get_predicted_damage(other), " damage\n")
				

func _cursor_action_player_unit_selected_state(action: int) -> void:
	var unit: Unit = _selected_unit()
	if action == Cursor.DESELECT:
		unit.position = unit_start_pos*Map.TILE_SIZE
		_deselect_unit(unit)
	elif action == Cursor.SELECT and cursor.tile in move_tiles:
		unit.position = unit_start_pos*Map.TILE_SIZE
		unit.path_to(arrows.path)
		cursor.can_move = false
		battle_state = STATE_PLAYER_UNIT_MOVED
		if (unit.tile == cursor.tile):
			_unit_move_finished(unit)
		

func _unit_move_finished(unit: Unit) -> void:
	var action: int = await ui.show_action_list(unit.get_valid_actions(cursor.tile, attack_tiles, unit_positions))
	_action_selected(action)


func _cursor_action_enemy_unit_selected_state(action: int) -> void:
	var unit: Unit = instance_from_id(selected_unit_id)
	if (action == Cursor.DESELECT):
		_deselect_unit(unit)
	elif (action == Cursor.SELECT):
		var new_unit: Unit = _unit_at(cursor.tile)
		if (new_unit != null and new_unit.get_instance_id() != unit.get_instance_id()):
			_select_unit(new_unit)
			if (new_unit.team == Teams.PLAYER):
				battle_state = STATE_PLAYER_UNIT_SELECTED
		else:
			_deselect_unit(unit)

func _cursor_action_player_attack_select(action: int) -> void:
	var unit: Unit = _selected_unit()
	if (action == Cursor.DESELECT):
		tile_highlight.clear_highlight()
		move_tiles = tile_highlight.get_move_tiles(unit, unit_positions)
		attack_tiles = tile_highlight.get_attack_tiles(unit, move_tiles)
		tile_highlight.highlight_tiles(move_tiles, attack_tiles)
		battle_state = STATE_PLAYER_UNIT_MOVED
		cursor.allowed_tiles = []
		cursor.tile = cursor_start_pos
		_attack_action_selected(unit)


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


