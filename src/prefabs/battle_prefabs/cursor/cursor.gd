extends Sprite2D
class_name Cursor

signal cursor_moved(tile: Vector2i)

var _input_dictionary: Dictionary = {
	"ui_left": Vector2i(-1, 0),
	"ui_right": Vector2i(1, 0),
	"ui_down": Vector2i(0, 1),
	"ui_up": Vector2i(0, -1)
}

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		var vector: Vector2i = _floor_position(get_global_mouse_position())
		if (vector*16 != Vector2i(position)):
			cursor_moved.emit(vector)
			_update_mouse_used(true)
		position = vector*Map.TILE_SIZE
	
	for action in _input_dictionary:
		var direction: Vector2i = _input_dictionary[action]
		if (Input.is_action_pressed(action)):
			position += Vector2(direction*Map.TILE_SIZE)
			_update_mouse_used(false)

func _floor_position(vector: Vector2) -> Vector2i:
	vector /= 16
	vector = vector.floor()
	return vector

func _update_mouse_used(using_mouse: bool)->void:
	if (using_mouse):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
