@tool
@icon("res://assets/icons/character.png")
extends Resource
class_name Character

@export var name: String : set = _set_name

@export var vocation: Vocation

@export_group("Stats")
@export var hp: int
@export var movement: int
@export var strength: int
@export var magic: int
@export var dexterity: int
@export var speed: int
@export var luck: int
@export var defence: int
@export var resistance: int

func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name
	
func get_unit_type() -> int:
	return vocation.unit_type_code
	
func get_movement() -> int:
	return movement + vocation.movement
