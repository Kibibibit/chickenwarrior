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
const STATE_BATTLE_ANIMATION: int = 8


var battle_state: int = STATE_PLAYER_TURN
var map: Map : set = set_map
var units: Dictionary = {}
var unit_positions: Dictionary = {}

var selected_unit_id: int = Constants.NULL_ID
var unit_start_pos: Vector2i
var cursor_start_pos: Vector2i

var move_tiles: Array[Vector2i]
var attack_tiles: Array[Vector2i]



var attacking_unit: Unit
var defending_unit: Unit

@onready
var camera: BattleCamera = $Camera2D
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
			await _cursor_action_player_attack_select(action)
		STATE_ENEMY_UNIT_SELECTED:
			_cursor_action_enemy_unit_selected_state(action)
	
func _process(_delta) -> void:
	if (battle_state != STATE_ENEMY_TURN):
		var all_moved: bool = true
		for unit in units.values():
			if (unit is Unit):
				if (unit.team == Teams.PLAYER && not unit.moved):
					all_moved = false
					break
		if (all_moved):
			cursor.can_move = false
			cursor.visible = false
			for unit in units.values():
				unit.moved = false
			battle_state = STATE_ENEMY_TURN
			run_enemy_turn()

func _cursor_moved(tile: Vector2i) -> void:
	ui.set_tile_type(map.get_tile_type(tile))
	match battle_state:
		STATE_PLAYER_TURN:
			_cursor_moved_player_turn_state(tile)
		STATE_PLAYER_UNIT_SELECTED:
			_cursor_moved_player_unit_selected_state(tile)
		STATE_PLAYER_ATTACK_SELECT:
			_cursor_moved_player_attack_select(tile)
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
	unit.unhighlight()
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
		cursor.tile = unit.tile
		arrows.clear_arrows()
		unit.highlight()
		battle_state = STATE_PLAYER_UNIT_SELECTED

func _attack_action_selected(unit: Unit) -> void:
	var weapon: Weapon = await ui.show_weapon_list(unit)
	if (weapon == null):
		_unit_move_finished(unit)
		return
	else:
		unit.equip_weapon(weapon)
		battle_state = STATE_PLAYER_ATTACK_SELECT
		tile_highlight.clear_highlight()
		attack_tiles = tile_highlight.get_attack_tiles_in_range(cursor.tile, weapon)
		var filtered_tiles: Array[Vector2i] = attack_tiles.filter(_attack_unit_filter)
		cursor_start_pos = cursor.tile
		tile_highlight.highlight_tiles([], attack_tiles)
		arrows.clear_arrows()
		cursor.allowed_tiles = filtered_tiles.duplicate()
		cursor.tile = filtered_tiles[0]
		_cursor_moved_player_attack_select(filtered_tiles[0])

func _attack_unit_filter(tile: Vector2i) -> bool:
	if (unit_positions.has(tile)):
		return _unit_at(tile).team == Teams.ENEMY
	return false

func _move_unit(unit: Unit) -> void:
	unit_positions.erase(unit.tile)
	unit.tile = cursor.tile
	unit_positions[cursor.tile] = unit.get_instance_id()
	unit.current_tile_type = map.get_tile_type(cursor.tile)
	unit.moved = true
	for u in units.values():
		u.unhighlight()
		
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
		ui.hide_attack_panel()
		_attack_action_selected(unit)
	if (action == Cursor.SELECT):
		attacking_unit = unit
		defending_unit = _unit_at(cursor.tile)
		tile_highlight.clear_highlight()
		cursor.allowed_tiles=[]
		cursor.tile = cursor_start_pos
		cursor.visible = false
		ui.hide_attack_panel()
		move_tiles = []
		attack_tiles = []
		battle_state = STATE_BATTLE_ANIMATION
		await _battle_animation_play()
		_move_unit(unit)
		_deselect_unit(unit)
		if (unit.hp <= 0):
			await kill_unit(unit)
		else:
			unit.moved = true
		cursor.visible = true
		cursor.can_move = true
		
		battle_state = STATE_PLAYER_TURN

func _cursor_moved_player_turn_state(tile: Vector2i) -> void:
	var unit: Unit = _unit_at(tile)
	ui.set_unit(unit)
	if (unit != null):
		if (unit.team == Teams.PLAYER and not unit.moved):
			unit.highlight()
	else:
		for unit_id in units:
			var u: Unit = units[unit_id]
			u.unhighlight()
	

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

func _cursor_moved_player_attack_select(tile: Vector2i) -> void:
	var enemy: Unit = _unit_at(tile)
	var unit = _selected_unit()
	ui.show_attack_panel(unit, enemy)
	var direction = Vector2i((unit.position - enemy.position).normalized())
	if (direction.x != 0 && direction.y != 0):
		direction.y = 0
	unit.set_walk_animation(direction)


func _direction(a: Unit, b:Unit) -> Vector2i:
	var direction = Vector2i((a.position - b.position).normalized())
	if (direction.x != 0 && direction.y != 0):
		direction.y = 0
	return direction

func _battle_animation_play() -> void:
	
	attacking_unit.set_walk_animation(_direction(attacking_unit, defending_unit))
	defending_unit.set_walk_animation(_direction(defending_unit, attacking_unit))
	
	var attacks: Array[int] = []
	var attackers: Array[bool] = []
	var attack_crits: Array[bool] = []
	
	var attacker_attacks_per_attack = attacking_unit.get_weapon_attack_count()
	var attacker_attack_sets = attacking_unit.get_speed_attack_count(defending_unit)
	
	if (not attacking_unit.can_attack(defending_unit)):
		attacker_attack_sets = 0
	
	var defender_attacks_per_attack = defending_unit.get_weapon_attack_count()
	var defender_attack_sets = defending_unit.get_speed_attack_count(attacking_unit)
	
	if (not defending_unit.can_attack(attacking_unit)):
		defender_attack_sets = 0
	
	var attacker_crit_chance = attacking_unit.get_crit_chance(defending_unit)
	var defender_crit_chance = defending_unit.get_crit_chance(attacking_unit)
	
	
	attacking_unit.attack_hit.connect(_attack_hit.bind(defending_unit))
	defending_unit.attack_hit.connect(_attack_hit.bind(attacking_unit))
	
	var attacker_hp = attacking_unit.hp
	var defender_hp = defending_unit.hp
	
	while (
		(attacker_attack_sets > 0 or defender_attack_sets > 0) and
		attacker_hp > 0 and
		defender_hp > 0
	 ):
		if (attacker_attack_sets > 0):
			for i in attacker_attacks_per_attack:
				var damage: int = _roll_attack(attacking_unit, defending_unit)
				var crit: bool = RNG.rn1(attacker_crit_chance)
				attacks.append(damage)
				attack_crits.append(crit)
				attackers.append(true)
				if (crit):
					damage *= 3
				defender_hp -= max(0, damage)
				if (defender_hp <= 0):
					break
			attacker_attack_sets -= 1
		if (defender_hp <= 0):
			break
		if (defender_attack_sets > 0):
			for i in defender_attacks_per_attack:
				var damage = _roll_attack(defending_unit, attacking_unit)
				var crit: bool = RNG.rn1(defender_crit_chance)
				attacks.append(damage)
				attack_crits.append(crit)
				if (crit):
					damage *= 3
				attackers.append(false)
				attacker_hp -= max(0, damage)
				if (attacker_hp <= 0):
					break
			defender_attack_sets -= 1
	
	for i in attacks.size():
		var unit_a: Unit
		var unit_b: Unit
		if (attackers[i]):
			unit_a = attacking_unit
			unit_b = defending_unit
		else:
			unit_a = defending_unit
			unit_b = attacking_unit
		var damage: int = attacks[i]
		var miss: bool = damage < 0
		var crit: bool = attack_crits[i] and not miss
		
		if (miss):
			damage = 0
		if (crit):
			damage *= 3
		if (crit):
			camera.trigger_screen_shake(4)
		await unit_a.attack_animation(unit_b.position, damage, crit, miss)
	attacking_unit.attack_hit.disconnect(_attack_hit)
	defending_unit.attack_hit.disconnect(_attack_hit)
	attacking_unit.unhighlight()
	defending_unit.unhighlight()
	
	if (selected_unit_id != attacking_unit.get_instance_id()):
		if (attacking_unit.hp <= 0):
			await kill_unit(attacking_unit)
	if (selected_unit_id != defending_unit.get_instance_id()):
		if (defending_unit.hp <= 0):
			await kill_unit(defending_unit)

func _roll_attack(unit_a: Unit, unit_b: Unit) -> int:
	var hits: bool = RNG.rn2(unit_a.get_hit_chance(unit_b))
	if (!hits):
		return -1 
	
	return unit_a.get_damage_per_attack(unit_b)

func _attack_hit(damage: int, unit: Unit) -> void:
	unit.hp -= damage

func run_enemy_turn() -> void:
	print("ENEMY TURN")
	battle_state = STATE_PLAYER_TURN
	cursor.can_move = true
	cursor.visible = true

func kill_unit(unit):
	units.erase(unit.get_instance_id())
	unit_positions.erase(unit.tile)
	await unit.kill()
