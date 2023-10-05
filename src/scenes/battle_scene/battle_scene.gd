extends Node2D
class_name BattleScene

var map: Map : set = set_map

var units: Dictionary = {}

@onready
var camera: Camera2D = $Camera2D


func set_map(p_map: Map):
	assert(map == null, "Tried to reset map!")
	map = p_map

func _ready() -> void:
	assert(map != null, "Tried to instantiate battle without map!")
	add_child(map)
	for unit in map.get_units():
		units[unit.get_instance_id()] = unit
