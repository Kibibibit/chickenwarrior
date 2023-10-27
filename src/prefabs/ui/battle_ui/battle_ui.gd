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
var attack_panel: AttackPanel = $CanvasLayer/InfoTiles/AttackPanel

@onready
var action_list: ActionList = $CanvasLayer/ActionList

func _ready():
	unit_panel.visible = false
	attack_panel.visible = false

func show_action_list(valid_actions: Array[int]) -> int:
	return await action_list.show_actions(valid_actions)

func show_weapon_list(unit: Unit) -> Weapon:
	var item_list: UnitInventoryList = inventory_list_scene.instantiate()
	canvas_layer.add_child(item_list)
	var item: Item = await item_list.select_item(unit.character.inventory)
	var weapon: Weapon = null
	if (item != null):
		if (item is Weapon):
			weapon = item as Weapon
	item_list.queue_free()
	canvas_layer.remove_child(item_list)
	return weapon
	

func show_attack_panel(player_unit: Unit, enemy_unit: Unit) -> void:
	attack_panel.show_attack(player_unit, enemy_unit)

func set_tile_type(tile_type: StringName) -> void:
	if (tile_type == TileTypes.VOID):
		tile_panel.visible = false
	else:
		tile_panel.visible = true
		var cost: int = TileTypes.get_cost(tile_type)
		var cost_string: String = ""
		var bonuses_string: String = ""
		
		var bonuses: Dictionary = TileTypes.get_all_stat_bonuses(tile_type)
		
		for key in bonuses:
			var label: String = ""
			var percent: String = ""
			if key == TileTypes.AVOID_BONUS:
				label = "Avoid"
				percent = "%"
			else:
				label = StatTypes.ABBREVIATION[key]
			var sign_label = "+"
			if (bonuses[key] < 0):
				sign_label = ""
			var bonus_string: String = "%s %s%s%s" % [label, sign_label, bonuses[key],percent]
			if (bonuses_string.is_empty()):
				bonuses_string = "Bonuses: %s" % bonus_string
			else:
				bonuses_string = "%s, %s" % [bonuses_string, bonus_string]
			
		
		if (cost == TileTypes.COST_MAX):
			cost_string = "Impassable"
		else:
			cost_string = "%s" % cost
		tile_label.text = "Tile: %s\nCost: %s\n%s" % [TileTypes.get_tile_name(tile_type), cost_string, bonuses_string]

func set_unit(unit: Unit) -> void:
	if (unit == null):
		unit_panel.visible = false
	else:
		unit_panel.visible = true
		var hp: int = unit.hp
		var max_hp: int = unit.get_max_hp()
		var name_: String = unit.character.name
		var class_name_: String = unit.character.vocation.name
		var mov: int = unit.get_movement()
		var lvl: int = unit.character.level
		unit_label.text = "%s (%s/%s)\n Lv. %s %s\nMovement: %s" % [name_, hp, max_hp, lvl, class_name_, mov]
