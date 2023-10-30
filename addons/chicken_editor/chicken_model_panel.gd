@tool
extends Control
class_name ChickenModelPanel


@onready
var item_list: ItemList = $HSplitContainer/ItemList


var get_item_title: Callable = _default_get_title
var get_item_icon: Callable = _default_get_icon
var items: Array = [] : set = set_items


func _default_get_title(item) -> String:
	return item.name

func _default_get_icon(item):
	return item.icon

func set_items(p_items: Array) -> void:
	items = p_items
	
	item_list.clear()
	
	for item in items:
		item_list.add_item(get_item_title.call(item), get_item_icon.call(item))
