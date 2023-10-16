extends Sprite2D
class_name Cursor

const SELECT: int = 0
const DESELECT: int = 1
const CURSOR_SPEED: int = 350

signal cursor_moved(tile: Vector2i)
signal cursor_action(action_type: int)

var tile: Vector2i = Vector2i(0,0)
var map_rect: Rect2i
var can_move: bool = false

var _input_dictionary: Dictionary = {
	"ui_left": Vector2i(-1, 0),
	"ui_right": Vector2i(1, 0),
	"ui_down": Vector2i(0, 1),
	"ui_up": Vector2i(0, -1)
}

func _unhandled_input(event: InputEvent) -> void:
	if (not can_move):
		return
	if (event is InputEventMouseMotion):
		var vector: Vector2i = _floor_position(get_global_mouse_position())
		_update_mouse_used(true)
		_update_position(vector, true)
	
	for action in _input_dictionary:
		var direction: Vector2i = _input_dictionary[action]
		if (Input.is_action_pressed(action)):
			_update_mouse_used(false)
			_update_position(tile+direction, false)
			break
	
	var clicked: int = -1
	if (event is InputEventMouseButton):
		if (event.pressed):
			if (event.button_index == MOUSE_BUTTON_LEFT):
				clicked = SELECT
			elif(event.button_index == MOUSE_BUTTON_RIGHT):
				clicked = DESELECT
	
	if (Input.is_action_just_released("ui_accept") or clicked == SELECT):
		cursor_action.emit(SELECT)
	elif (Input.is_action_just_released("ui_text_backspace") or clicked == DESELECT):
		cursor_action.emit(DESELECT)

func _update_position(new_tile: Vector2i, used_mouse: bool):
	if (map_rect.has_point(new_tile)):
		if (new_tile != tile):
			tile = new_tile
			if (used_mouse):
				position = new_tile*Map.TILE_SIZE
			cursor_moved.emit(tile)

func _floor_position(vector: Vector2) -> Vector2i:
	vector /= 16
	vector = vector.floor()
	return vector

func _update_mouse_used(using_mouse: bool)->void:
	if (using_mouse):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	position.x = move_toward(position.x, tile.x * Map.TILE_SIZE, delta*CURSOR_SPEED)
	position.y = move_toward(position.y, tile.y * Map.TILE_SIZE, delta*CURSOR_SPEED)
