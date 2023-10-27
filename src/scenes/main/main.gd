extends Node2D

var battle_scene_resource: PackedScene = preload("res://src/scenes/battle_scene/battle_scene.tscn")
var test_map_resource: PackedScene = preload("res://src/prefabs/maps/test_map/test_map.tscn")

func _ready() -> void:
	
	WeaponLoader.load_weapons()
	
	var battle_scene: BattleScene = battle_scene_resource.instantiate()
	var map_scene: Map = test_map_resource.instantiate()
	battle_scene.map = map_scene
	
	add_child(battle_scene)
