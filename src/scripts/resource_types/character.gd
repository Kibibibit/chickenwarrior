@tool
@icon("res://assets/icons/character.png")
extends Resource
class_name Character

@export var name: String

@export_group("Stats")
@export var hp: int
@export var movement: int

func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name
