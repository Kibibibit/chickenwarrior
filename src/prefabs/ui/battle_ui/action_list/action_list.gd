extends Control
class_name ActionList

signal action_selected(action: int)

@onready
var _vbox: VBoxContainer = $VBoxContainer


var actions: Array[int] = []

func _ready() -> void:
	for child in _vbox.get_children():
		child.queue_free()
		_vbox.remove_child(child)

func _clear_actions() -> void:
	for child in _vbox.get_children():
		child.button_up.disconnect(_action_selected)
		child.queue_free()
		_vbox.remove_child(child)

func show_actions(p_actions: Array[int]) -> int:
	var focused: bool = false
	actions = p_actions
	await get_tree().physics_frame
	for action in actions:
		_add_action(action, focused)
		if (not focused):
			focused = true
	
	visible = true
	var action: int = await action_selected
	visible = false
	
	await get_tree().physics_frame
	_clear_actions()
	return action


func _action_selected(action: int) -> void:
	action_selected.emit(action)

func _add_action(action: int, focused:bool) -> void:
	var button: Button = Button.new()
	button.text = Unit.get_action_label(action)
	button.button_up.connect(_action_selected.bind(action))
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	_vbox.add_child(button)
	if (not focused):
		button.grab_focus()


func _unhandled_input(event):
	if (not visible):
		return
	if (event is InputEventMouseButton):
		if (event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
			_action_selected(Unit.ACTION_NONE)
	if (Input.is_action_just_released("ui_text_backspace")):
		_action_selected(Unit.ACTION_NONE)
