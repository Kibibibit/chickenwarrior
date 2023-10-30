extends Control
class_name UnitInventoryList


signal item_selected(item: Item)

@onready
var _vbox: VBoxContainer = $VBoxContainer


var items: Array[Item] = []

func _ready() -> void:
	for child in _vbox.get_children():
		child.queue_free()
		_vbox.remove_child(child)

func _clear_items() -> void:
	for child in _vbox.get_children():
		if (not child.disabled):
			child.button_up.disconnect(_item_selected)
		child.queue_free()
		_vbox.remove_child(child)

func select_item(
	unit: Unit, 
	can_use_only: bool = false, 
	weapon_only: bool = false, 
	from: Vector2i = Vector2i(0,0), 
	enemies: Array[Unit]= []
) -> Item:
	var focused: bool = false
	items = unit.character.inventory
	
	await get_tree().physics_frame
	
	for item in items:
		var can_use_item: bool = unit.character.can_use(item)
		var is_weapon: bool = item is Weapon
		if (not weapon_only or is_weapon):
			_add_item(item, focused, not can_use_only or can_use_item)
			if (not focused):
				focused = true
	
	visible = true
	var item: Item = await item_selected
	
	await get_tree().physics_frame
	visible = false
	_clear_items()
	return item
	
func _item_selected(action: Item) -> void:
	item_selected.emit(action)

func _add_item(item: Item, focused:bool, allowed: bool = true) -> void:
	var button: Button = Button.new()
	button.text = item.name
	button.icon = item.icon
	if (allowed):
		button.button_up.connect(_item_selected.bind(item))
	else:
		button.disabled = true
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	_vbox.add_child(button)
	if (not focused):
		button.grab_focus()


func _unhandled_input(event):
	if (not visible):
		return
	if (event is InputEventMouseButton):
		if (event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
			_item_selected(null)
	if (Input.is_action_just_released("ui_text_backspace")):
		_item_selected(null)
		
