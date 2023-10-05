extends Node2D

var battle_scene_resource: PackedScene = preload("res://src/scenes/battle_scene/battle_scene.tscn")
var test_map_resource: PackedScene = preload("res://src/prefabs/maps/test_map/test_map.tscn")
var iron_sword: Weapon = preload("res://resources/items/weapons/iron_sword.tres")


func _ready() -> void:
	var battle_scene: BattleScene = battle_scene_resource.instantiate()
	var map_scene: Map = test_map_resource.instantiate()
	battle_scene.map = map_scene
	
	print(iron_sword.min_rank)
	
	add_child(battle_scene)
