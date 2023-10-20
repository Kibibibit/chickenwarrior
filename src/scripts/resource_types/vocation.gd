@tool
@icon("res://assets/icons/vocation.png")
extends Resource
class_name Vocation


@export var name: String: set = _set_name
@export_enum("Infantry:0", "Armoured:1", "Cavalry:2", "Flier:3") var unit_type_code: int
@export_flags("Sword","Lance","Axe","Bow","Magic") var useable_weapons: int

## Item to promote to this vocation
@export var promotion_item: Item

## Other vocations that this vocation can promote to
@export var promotions: Array[Vocation]

@export_group("Bonus Stats")
@export var hp: int
@export var movement: int
@export var strength: int
@export var magic: int
@export var dexterity: int
@export var speed: int
@export var luck: int
@export var defence: int
@export var resistance: int

@export_group("Growth Rates")
@export var hp_growth: int






func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name
