@tool
@icon("res://assets/icons/weapon.png")
extends Item
class_name Weapon

const SWORD: int = 0
const LANCE: int = 1
const AXE: int = 2

const BASE_STRENGTH: int = 0
const BASE_MAGIC: int = 1
const BASE_DEX: int = 2

const RANK_E: int = 0
const RANK_D: int = 1
const RANK_C: int = 2
const RANK_B: int = 3
const RANK_A: int = 4

@export_enum("Sword", "Lance", "Axe", "Bow") var weapon_type: int
@export_enum("Strength", "Magic", "Dexterity") var base_stat: int
@export var might: int
@export_range(0, 100) var hit_chance: int
@export_range(0, 100) var crit_chance: int
@export var weight: int
## The minimum rank needed to wield this weapon
@export_enum("E","D","C","B","A") var min_rank: int
## How many consecutive hits per attack this weapon does.
@export var attack_count: int = 1

@export_group("Range")
@export var min_range: int
@export var max_range: int
