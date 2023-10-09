extends Control
class_name BattleUI

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

signal action_selected(action: int)

func _ready() -> void:
	action_list.action_selected.connect(_action_selected)

func _action_selected(action: int):
	action_selected.emit(action)

func show_action_list(unit:Unit, valid_actions: Array[int]) -> void:
	action_list.position = unit.get_screen_transform().origin+Vector2(Map.TILE_SIZE, 0)*unit.get_screen_transform().get_scale().x
	action_list.show_actions(valid_actions)

func hide_action_list() -> void:
	action_list.hide_actions()

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
