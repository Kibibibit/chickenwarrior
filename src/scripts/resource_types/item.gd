@tool
@icon("res://assets/icons/item.png")
extends Resource
class_name Item

@export var name: String: set = _set_name
@export var breakable: bool = true
@export var max_uses: int
var uses: int = max_uses

func _set_name(p_name: String) -> void:
	name = p_name
	resource_name = p_name
