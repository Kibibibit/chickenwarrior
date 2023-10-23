@tool
@icon("res://assets/icons/character.png")
extends Resource
class_name Character

@export var name: String : set = _set_name

@export var vocation: Vocation

@export var inventory: Array[Item] = []

@export_range(1,255) var level: int = 1
@export_range(0,99) var xp: int = 0

@export_group("Stats")
@export var hp: int
@export var strength: int
@export var magic: int
@export var dexterity: int
@export var speed: int
@export var luck: int
@export var defence: int
@export var resistance: int

@export var movement: int

@export_group("Growth Rates")
@export var hp_growth: int
@export var strength_growth: int
@export var magic_growth: int
@export var dexterity_growth: int
@export var speed_growth: int
@export var luck_growth: int
@export var defence_growth: int
@export var resistance_growth: int


var _level_up_funcs: Array[Array] = [
	[get_hp_growth, _set_hp, get_max_hp],
	[get_strength_growth, _set_strength, get_strength],
	[get_magic_growth, _set_magic, get_magic],
	[get_dexterity_growth, _set_dexterity, get_dexterity],
	[get_speed_growth, _set_speed, get_speed],
	[get_luck_growth, _set_luck, get_luck],
	[get_defence_growth, _set_defence, get_defence],
	[get_resistance_growth, _set_resistance, get_resistance]
]

func _promote_funcs(v: Vocation) -> Array[Array]:
	return [
		[v.get_hp, _set_hp, get_max_hp],
		[v.get_strength, _set_strength, get_strength],
		[v.get_magic, _set_magic, get_magic],
		[v.get_dexterity, _set_dexterity, get_dexterity],
		[v.get_speed, _set_speed, get_speed],
		[v.get_luck, _set_luck, get_luck],
		[v.get_defence, _set_defence, get_defence],
		[v.get_resistance, _set_resistance, get_resistance]
	]



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

func can_use(item: Item) -> bool:
	if (item is Weapon):
		var can_use_weapon_type: bool =  vocation.is_weapon_type_useable(item.weapon_type)
		var can_use_weapon_level: bool = true
		return can_use_weapon_type and can_use_weapon_level
	else:
		### Handle things like vulnearies and stuff here
		return true
	

func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name
	
func get_unit_type() -> int:
	return vocation.unit_type_code

func increase_level_to(new_level: int) -> void:
	if (level < new_level):
		while (level != new_level):
			level_up()
	else:
		push_warning("Trying to drop level with `increase_level_to`")
		level = new_level

func level_up() -> void:
	for func_set in _level_up_funcs:
		var growth_getter: Callable = func_set[0]
		var stat_setter: Callable = func_set[1]
		var stat_getter: Callable = func_set[2]
		
		var growth_chance: int = growth_getter.call()
		var new_stat_value: int = stat_getter.call()
		while (growth_chance >= 100):
			growth_chance -= 100
			new_stat_value += 1
		var roll: int = randi_range(0,99)
		if (roll <= growth_chance):
			new_stat_value += 1
		stat_setter.call(new_stat_value)
	level += 1

func promote_to(new_vocation: Vocation) -> void:
	for func_set in _promote_funcs(new_vocation):
		var min_value = func_set[0].call()
		var current_value = func_set[2].call()
		if (min_value > current_value):
			func_set[1].call(min_value)
	vocation = new_vocation

func get_movement() -> int:
	return movement+vocation.movement

func get_max_hp() -> int:
	return hp
func get_strength() -> int:
	return strength
func get_magic() -> int:
	return magic
func get_dexterity() -> int:
	return dexterity
func get_speed() -> int:
	return speed
func get_luck() -> int:
	return luck
func get_defence() -> int:
	return defence
func get_resistance() -> int:
	return resistance

func _set_hp(p_hp: int) -> void:
	hp = p_hp
func _set_strength(p_str: int) -> void:
	strength = p_str
func _set_magic(p_mag: int) -> void:
	magic = p_mag
func _set_dexterity(p_dex: int) -> void:
	dexterity = p_dex
func _set_speed(p_spd: int) -> void:
	speed = p_spd
func _set_luck(p_lck: int) -> void:
	luck = p_lck
func _set_defence(p_def: int) -> void:
	defence = p_def
func _set_resistance(p_res:int) -> void:
	resistance = p_res

func get_hp_growth() -> int:
	return hp_growth + vocation.hp_growth
func get_strength_growth() -> int:
	return strength_growth + vocation.strength_growth
func get_magic_growth() -> int:
	return magic_growth + vocation.magic_growth
func get_dexterity_growth() -> int:
	return dexterity_growth + vocation.dexterity_growth
func get_speed_growth() -> int:
	return speed_growth + vocation.speed_growth
func get_luck_growth() -> int:
	return luck_growth + vocation.luck_growth
func get_defence_growth() -> int:
	return defence_growth + vocation.defence_growth
func get_resistance_growth() -> int:
	return resistance_growth + vocation.resistance_growth

func print_stats() -> void:
	print({
		"hp":get_max_hp(),
		"mov":get_movement(),
		"str":get_strength(),
		"mag":get_magic(),
		"dex":get_dexterity(),
		"spd":get_speed(),
		"lck":get_luck(),
		"res":get_resistance(),
		"def":get_defence()
	})
