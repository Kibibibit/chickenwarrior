@tool
@icon("res://assets/icons/character.png")
extends Resource
class_name Character

@export var name: String : set = _set_name

@export var vocation: Vocation

@export var inventory: Array[Item] = []

@export_range(1,255) var level: int = 1
@export_range(0,99) var xp: int = 0


@export var stats: Dictionary = {} : set = _set_stats
@export var growth_rates: Dictionary = {} : set = _set_growth_rates
@export var movement: int


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
	for stat in StatTypes.ALL:
		var growth_chance: int =  growth_rates[stat] + vocation.growth_rates[stat]
		var new_stat_value: int = stats[stat]
		while (growth_chance >= 100):
			growth_chance -= 100
			new_stat_value += 1
		var roll: int = randi_range(0,99)
		if (roll <= growth_chance):
			new_stat_value += 1
		stats[stat] = new_stat_value
	level += 1

func promote_to(new_vocation: Vocation) -> void:
	for stat in StatTypes.ALL:
		var min_value = vocation.min_stats[stat]
		var current_value = stats[stat]
		if (min_value > current_value):
			stats[stat] = min_value
	vocation = new_vocation

func get_movement() -> int:
	return movement+vocation.movement

func get_max_hp() -> int:
	return stats[StatTypes.HP]

func get_stat(stat: StringName) -> int:
	return stats[stat]


func _set_stats(p_stats: Dictionary) -> void:
	if (stats == null):
		stats = {}
	for stat in StatTypes.ALL:
		if (p_stats != null):
			if (stat in p_stats):
				stats[stat] = p_stats[stat]
			else:
				stats[stat] = 0
		else:
			stats[stat] = 0
			
func _set_growth_rates(p_stats: Dictionary) -> void:
	if (growth_rates == null):
		growth_rates = {}
	for stat in StatTypes.ALL:
		if (p_stats != null):
			
			if (stat in p_stats):
				growth_rates[stat] = p_stats[stat]
			else:
				growth_rates[stat] = 0
		else:
			growth_rates[stat] = 0
	

func equip_weapon(weapon: Weapon) -> void:
	var index: int = 0
	var found: bool = false
	for item in inventory:
		if (item.get_instance_id() == weapon.get_instance_id()):
			found = true
			break
		index += 1
	if (found):
		inventory.remove_at(index)
		inventory.push_front(weapon)

func get_equipped_weapon() -> Weapon:
	for item in inventory:
		if (item is Weapon && can_use(item)):
			return item as Weapon
	return null

func print_stats() -> void:
	print(stats)
