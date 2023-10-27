extends Node

var _weapon_dict: Dictionary = {}
var unarmed: Weapon

func _ready():
	_create_unarmed()



func load_weapons() -> void:

	var file_access := DirAccess.open(Constants.WEAPON_FILE_PATH)
	
	var weapon_files: PackedStringArray = file_access.get_files()
	
	for filename in weapon_files:
		var path := "%s%s" % [Constants.WEAPON_FILE_PATH, filename]
		var resource: Weapon = load(path)
		
		if (resource.item_id in _weapon_dict):
			push_warning("Found duplicate weapon item_id %s" % resource.item_id)
		_weapon_dict[resource.item_id] = resource


func get_weapon(weapon_id: StringName) -> Weapon:
	if (weapon_id in _weapon_dict):
		return _weapon_dict[weapon_id].duplicate()
	else:
		push_warning("Unknown weapon_id %s, returning unarmed" % weapon_id)
		return unarmed


func _create_unarmed() -> void:
	unarmed = Weapon.new()
	unarmed.weapon_type = Weapon.UNARMED
	unarmed.base_stat = Weapon.BASE_STRENGTH
	unarmed.might = 0
	unarmed.hit_chance = 95
	unarmed.crit_chance = 5
	unarmed.weight = 0
	unarmed.min_rank = Weapon.RANK_E
	unarmed.attack_count = 2
	unarmed.type_bonuses = 0
	unarmed.min_range = 1
	unarmed.max_range = 1
	unarmed.name = "Unarmed"
	unarmed.breakable = false
	unarmed.max_uses = 0
	unarmed.icon = preload("res://assets/icons/fist.png")
	unarmed.item_id = WeaponId.UNARMED
	unarmed.resource_name = "Unarmed"
	_weapon_dict[WeaponId.UNARMED] = unarmed



