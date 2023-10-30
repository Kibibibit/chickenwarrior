extends Resource
class_name InventoryItem


@export var item_id: StringName
@export var uses: int



func is_weapon() -> bool:
	return WeaponLoader.is_weapon(item_id)


func get_as_weapon() -> Weapon:
	if (is_weapon()):
		return WeaponLoader.get_weapon(item_id)
	else:
		return null
