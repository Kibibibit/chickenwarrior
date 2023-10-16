extends Control
class_name BattleUI


const inventory_list_scene: PackedScene = preload("res://src/prefabs/ui/unit_inventory_list/unit_inventory_list.tscn")

@onready
var canvas_layer: CanvasLayer = $CanvasLayer
@onready
var tile_panel: Panel = $CanvasLayer/InfoTiles/TilePanel
@onready
var tile_label: Label = $CanvasLayer/InfoTiles/TilePanel/TileLabel
@onready
var unit_panel: Panel = $CanvasLayer/InfoTiles/UnitPanel
@onready
var unit_label: Label = $CanvasLayer/InfoTiles/UnitPanel/UnitLabel

@onready
var action_list: ActionList = $CanvasLayer/ActionList



func show_action_list(valid_actions: Array[int]) -> int:
	return await action_list.show_actions(valid_actions)

func show_weapon_list(unit: Unit) -> Weapon:
	var item_list: UnitInventoryList = inventory_list_scene.instantiate()
	canvas_layer.add_child(item_list)
	var item: Item = await item_list.select_item(unit.inventory)
	var weapon: Weapon = null
	if (item != null):
		if (item is Weapon):
			weapon = item as Weapon
	item_list.queue_free()
	canvas_layer.remove_child(item_list)
	return weapon
	


func set_tile_type(tile_type: StringName) -> void:
	if (tile_type == TileTypes.VOID):
		tile_panel.visible = false
	else:
		tile_panel.visible = true
		var cost: int = TileTypes.get_cost(tile_type)
		var cost_string: String = ""
		if (cost == TileTypes.COST_MAX):
			cost_string = "Impassable"
		else:
			cost_string = "%s" % cost
		tile_label.text = "Tile: %s\nCost: %s" % [TileTypes.get_tile_name(tile_type), cost_string]

func set_unit(unit: Unit) -> void:
	if (unit == null):
		unit_panel.visible = false
	else:
		unit_panel.visible = true
		var hp: int = unit.hp
		var max_hp: int = unit.character.hp
		var name_: String = unit.character.name
		var mov: int = unit.character.movement
		unit_label.text = "Character: %s (%s/%s)\nMovement: %s" % [name_, hp, max_hp, mov]
