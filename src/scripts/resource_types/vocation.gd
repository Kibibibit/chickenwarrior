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

@export_group("Bonus Stats")
## When a unit is this vocation, they get this much extra max hp
@export var hp: int
## When a unit is this vocation, they get this much extra movement
@export var movement: int
## When a unit is this vocation, they get this much extra strength
@export var strength: int
## When a unit is this vocation, they get this much extra magic
@export var magic: int
## When a unit is this vocation, they get this much extra dexterity
@export var dexterity: int
## When a unit is this vocation, they get this much extra speed
@export var speed: int
## When a unit is this vocation, they get this much extra luck
@export var luck: int
## When a unit is this vocation, they get this much extra defence
@export var defence: int
## When a unit is this vocation, they get this much extra resistance
@export var resistance: int

@export_group("Growth Rates")
## When a unit with this vocation, their hp growth rate is increased by this much
@export var hp_growth: int


## This setter is just helpful for setting [resource_name as well]
func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name

## Returns true if this vocation can use the passed weapon type
func is_weapon_type_useable(weapon_type: int) -> bool:
	var mask: int = roundi(pow(2, weapon_type))
	return useable_weapons & mask > 0
