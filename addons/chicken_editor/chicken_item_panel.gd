@tool
extends Control
class_name ChickenItemPanel


@onready
var tab_bar: TabBar = $MarginContainer/VBoxContainer/TabBar

@onready
var sword_panel: ChickenModelPanel = $MarginContainer/VBoxContainer/TabChild/SwordModelPanel
@onready
var axe_panel: ChickenModelPanel = $MarginContainer/VBoxContainer/TabChild/AxeModelPanel
@onready
var lance_panel: ChickenModelPanel = $MarginContainer/VBoxContainer/TabChild/LanceModelPanel
@onready
var bow_panel: ChickenModelPanel = $MarginContainer/VBoxContainer/TabChild/BowModelPanel

@onready
var tabs: Dictionary = {
	0: sword_panel,
	1: axe_panel,
	2: lance_panel,
	3: bow_panel
}


var get_weapon_ids: Callable
var get_weapon_from_id: Callable
var callbacks_set: bool = false : set = _set_callbacks_set

func _ready():
	self.visibility_changed.connect(_on_show)
	tab_bar.tab_changed.connect(_tab_changed)


func _set_callbacks_set(p_value: bool) -> void:
	callbacks_set = p_value
	if (p_value):
		load_weapons()


func _tab_changed(new_tab: int) -> void:
	for tab in tabs.values():
		tab.visible = false
	tabs[new_tab].visible = true

func _set_weapon_callback(callback: Callable) -> void:
	get_weapon_ids = callback
	load_weapons()

func _on_show():
	if (visible):
		load_weapons()


func load_weapons() -> void:
	var swords: Array[Weapon] = []
	var axes: Array[Weapon] = []
	var lances: Array[Weapon] = []
	var bows: Array[Weapon] = []
	var weapon_ids: Array[StringName] = get_weapon_ids.call()
	for weapon_id in weapon_ids:
		var weapon: Weapon = get_weapon_from_id.call(weapon_id)
		match weapon.weapon_type:
			Weapon.SWORD:
				swords.append(weapon)
			Weapon.AXE:
				axes.append(weapon)
			Weapon.LANCE:
				lances.append(weapon)
			Weapon.BOW:
				bows.append(weapon)
			_:
				pass
	sword_panel.set_items(swords)
	axe_panel.set_items(axes)
	lance_panel.set_items(lances)
	bow_panel.set_items(bows)
