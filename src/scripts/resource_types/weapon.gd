## --- WEAPON ---
## An extension of the Item resource, that represents weapons.
## Includes all stats needed to represent a weapon. Remember to
## duplicate this resource before giving it to a unit, or they will
## affect the durability of all weapons of the same type.
@tool
@icon("res://assets/icons/weapon.png")
extends Item
class_name Weapon

## The id for a sword weapon type. Equal to 0
const SWORD: int = 0
## The id for a lance weapon type. Equal to 1
const LANCE: int = 1
## The id for an axe weapon type. Equal to 2
const AXE: int = 2
## The id for a bow weapon type. Equal to 3
const BOW: int = 3

## A list of weapon types. Primarily used in 
## [Vocation] to determine if it can use a weapon type
const WEAPON_TYPES: Array[int] = [
	SWORD, LANCE, AXE, BOW
]

## Set [base_stat] to this value if the weapon uses Strength as its base stat.
const BASE_STRENGTH: int = 0
## Set [base_stat] to this value if the weapon uses Magic as its base stat.
const BASE_MAGIC: int = 1
## Set [base_stat] to this value if the weapon uses Dexterity as its base stat.
const BASE_DEX: int = 2

## The [min_rank] value for a weapon E Rank, the minimum amount.
const RANK_E: int = 0
## The [min_rank] value for a weapon D Rank.
const RANK_D: int = 1
## The [min_rank] value for a weapon C Rank.
const RANK_C: int = 2
## The [min_rank] value for a weapon B Rank.
const RANK_B: int = 3
## The [min_rank] value for a weapon A Rank.
const RANK_A: int = 4
## The [min_rank] value for a weapon S Rank, the maximum amount.
const RANK_S: int = 5

## The type of this weapon. Should be one of [SWORD], [LANCE], [AXE], ... and so on.
@export_enum("Sword", "Lance", "Axe", "Bow") var weapon_type: int : set = _set_weapon_type
## The base stat that this weapon uses to calculate the attack stat. Should be on of [BASE_STRENGTH], [BASE_MAGIC] and so on.
@export_enum("Strength", "Magic") var base_stat: int
## The base damage of this weapon, modified by the base stat of the unit using it.
@export var might: int
## The base hit chance of this weapon. Should be an integer between 0 and 100, where 0 is 0% chance to hit and 100 is a 100% chance to hit
@export_range(0, 100) var hit_chance: int
## The base critical chance of this weapon. Should be an integer between 0 and 100, where 0 is 0% chance to crit and 100 is a 100% chance to crit
@export_range(0, 100) var crit_chance: int
## The weight of this weapon. Modifies the user's speed stat in combat. Heavier weapons make units less likely to hit and dodge.
@export var weight: int
## The minimum rank needed to wield this weapon. Should be set to one of [RANK_E], [RANK_D], [RANK_C], ... and so on.
@export_enum("E","D","C","B","A", "S") var min_rank: int
## How many consecutive hits per attack this weapon does per attack.
## For example, if set to 2, each standard attack will trigger twice.
@export var attack_count: int = 1

## What unit types this weapon has an advantage over
@export_flags("Infantry","Armoured","Cavalry", "Flier") var type_bonuses: int

@export_group("Range")
## The minimum range that this weapon can attack at. For most weapons, this should be 1.
@export var min_range: int = 1
## THe maximum range that this weapon can attack at. For melee weapons, this should be 1.
@export var max_range: int = 1

## Returns true if this weapon has a type advantage against the given unit type
func has_type_bonus(unit_type_code: int) -> bool:
	var mask: int = roundi(pow(2, unit_type_code))
	return type_bonuses & mask > 0

func get_weapon_stat_code() -> StringName:
	match base_stat:
		BASE_MAGIC:
			return StatTypes.MAGIC
		BASE_DEX:
			return StatTypes.DEXTERITY
		_:
			return StatTypes.STRENGTH

func _set_weapon_type(p_weapon_type: int) -> void:
	weapon_type = p_weapon_type
	## Bows inherently have an advantage over fliers
	if (weapon_type == BOW):
		if (!has_type_bonus(UnitTypes.FLIER)):
			type_bonuses +=  1 << UnitTypes.FLIER
	
