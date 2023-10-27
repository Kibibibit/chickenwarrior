## --- VOCATION ---
## Vocations (I wanted to call them classes but this saves a lot of name conflicts)
## are the types of soldiers that units will fall into.
## Determines the character's usable weapons, and modifies their growth rates and stats.
@tool
@icon("res://assets/icons/vocation.png")
extends Resource
class_name Vocation

## The name of this Vocation. A setter is used so that the [resource_name] flag
## matches the name, which just makes the editor look nicer
@export var name: String: set = _set_name

## The type of unit that this vocation falls under. Most units should be Infantry.
## The int values map to the codes in [UnitType]
@export_enum("Infantry:0", "Armoured:1", "Cavalry:2", "Flier:3") var unit_type_code: int

## A set of flags for the types of weapons this vocation can use. If you need to check
## if a certain weapon type is useable, call [is_weapon_type_useable]
@export_flags("Sword","Lance","Axe","Bow") var useable_weapons: int

## Item to promote to this vocation. We will need a subclass of Item for
## promotion items in the future.
@export var promotion_item: Item

## Other vocations that this vocation can promote to.
@export var promotions: Array[Vocation]

## When a unit is this vocation, they get this much extra movement
@export var movement: int

@export var min_stats: Dictionary = {} : set = _set_stats
@export var growth_rates: Dictionary = {} : set = _set_growth_rates


## This setter is just helpful for setting [resource_name as well]
func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name

## Returns true if this vocation can use the passed weapon type
func is_weapon_type_useable(weapon_type: int) -> bool:
	if (weapon_type == -1):
		return true
	var mask: int = roundi(pow(2, weapon_type))
	return useable_weapons & mask > 0


func _set_stats(p_stats: Dictionary) -> void:
	if (min_stats == null):
		min_stats = {}
	for stat in StatTypes.ALL:
		if (p_stats != null):
			if (stat in p_stats):
				min_stats[stat] = p_stats[stat]
			else:
				min_stats[stat] = 0
		else:
			min_stats[stat] = 0
			
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
