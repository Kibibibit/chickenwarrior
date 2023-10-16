extends Control
class_name UnitInventoryList


signal item_selected(item: Item)

@onready
var _vbox: VBoxContainer = $VBoxContainer


var items: Array[Item] = []
var is_focus: bool = false
var do_refocus: bool = false

func _ready() -> void:
	for child in _vbox.get_children():
		child.queue_free()
		_vbox.remove_child(child)


func _clear_items() -> void:
	for child in _vbox.get_children():
		child.button_up.disconnect(_item_selected)
		child.queue_free()
		_vbox.remove_child(child)

func select_item(inventory: Array[Item]) -> Item:
	var focused: bool = false
	items = inventory
	for item in items:
		_add_item(item, focused)
		if (not focused):
			focused = true
	
	visible = true
	var item: Item = await item_selected
	visible = false
	_clear_items()
	return item
	
func _item_selected(action: Item) -> void:
	item_selected.emit(action)

func _add_item(item: Item, focused:bool) -> void:
	var button: Button = Button.new()
	button.text = item.name
	button.icon = item.icon
	button.button_up.connect(_item_selected.bind(item))
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	_vbox.add_child(button)
	if (not focused):
		button.grab_focus()

func _process(_delta):
	if (visible and not is_focus):
		do_refocus = true
	elif (do_refocus and visible and not is_focus):
		is_focus = true
	elif (not visible):
		do_refocus = false
		is_focus = false

func _unhandled_input(event):
	if (not visible or not is_focus):
		return
	if (event is InputEventMouseButton):
		if (event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
			_item_selected(null)
	if (Input.is_action_just_released("ui_text_backspace")):
		_item_selected(null)
		
