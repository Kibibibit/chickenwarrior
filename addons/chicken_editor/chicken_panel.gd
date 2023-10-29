@tool
extends Control
class_name ChickenPanel


const WEAPON_PATH = "res://resources/items/weapons/"
enum DataType {WEAPON}

@onready var load_data_button: Button = $MarginContainer/MainVBox/TabBarContainer/LoadDataButton
@onready var tab_bar: TabBar = $MarginContainer/MainVBox/TabBarContainer/TabBar
@onready var item_panel: Control = $MarginContainer/MainVBox/ItemPanel

@onready
var tabs: Dictionary = {
	0: item_panel
}

var weapons: Dictionary = {}


func _ready() -> void:
	load_data_button.button_down.connect(_load_data)
	tab_bar.tab_changed.connect(_tab_changed)
	

func _tab_changed(new_tab: int) -> void:
	for tab in tabs.values():
		tab.visible = false
	tabs[new_tab].visible = true


## Move into different node
func _load_data() -> void:
	load_set(WEAPON_PATH, DataType.WEAPON)


func load_set(load_from: String, datatype: DataType) -> void:
	
	var directory: DirAccess = DirAccess.open(load_from)
	var files: PackedStringArray = directory.get_files()
	
	for file in files:
		var file_path = "%s%s" % [load_from, file]
		match datatype:
			DataType.WEAPON:
				load_weapon(file_path)
			_:
				print("Unknown")
		

func load_weapon(file_path: String) -> void:
	var weapon: Weapon = load(file_path)
	weapons[weapon.item_id] = weapon
