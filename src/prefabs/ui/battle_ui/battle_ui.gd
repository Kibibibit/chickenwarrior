extends Control
class_name BattleUI

@onready
var tile_panel: Panel = $CanvasLayer/Control/TilePanel
@onready
var tile_label: Label = $CanvasLayer/Control/TilePanel/TileLabel
@onready
var unit_panel: Panel = $CanvasLayer/Control/UnitPanel
@onready
var unit_label: Label = $CanvasLayer/Control/UnitPanel/UnitLabel





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
