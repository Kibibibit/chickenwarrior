extends Node2D
class_name Arrows

const LR_POINT: Vector2i = Vector2i(0,0)
const UD_POINT: Vector2i = Vector2i(0,1)
const R_POINT: Vector2i = Vector2i(1,0)
const U_POINT: Vector2i = Vector2i(1,1)
const D_POINT: Vector2i = Vector2i(2,0)
const L_POINT: Vector2i = Vector2i(2,1)
const DR_POINT: Vector2i = Vector2i(3,0)
const UR_POINT: Vector2i = Vector2i(3,1)
const DL_POINT: Vector2i = Vector2i(4,0)
const UL_POINT: Vector2i = Vector2i(4,1)
const L_END: Vector2i = Vector2i(5,0)
const D_END: Vector2i = Vector2i(5,1)
const U_END: Vector2i = Vector2i(6,0)
const R_END: Vector2i = Vector2i(6,1)

const START_POINTS: Dictionary = {
	Vector2i.UP: U_POINT,
	Vector2i.DOWN: D_POINT,
	Vector2i.LEFT: L_POINT,
	Vector2i.RIGHT: R_POINT
}
const END_POINTS: Dictionary = {
	Vector2i.UP: U_END,
	Vector2i.DOWN: D_END,
	Vector2i.LEFT: L_END,
	Vector2i.RIGHT: R_END
}
const CORNER_POINTS: Dictionary = {
	Vector2i.LEFT: {
		Vector2i.UP: UL_POINT,
		Vector2i.DOWN: DL_POINT,
	},
	Vector2i.RIGHT: {
		Vector2i.UP: UR_POINT,
		Vector2i.DOWN: DR_POINT
	},
	Vector2i.UP: {
		Vector2i.LEFT: UL_POINT,
		Vector2i.RIGHT: UR_POINT
	},
	Vector2i.DOWN: {
		Vector2i.LEFT: DL_POINT,
		Vector2i.RIGHT: DR_POINT
	},

}


var _arrow_texture: CompressedTexture2D = preload("res://assets/arrows.png")
var _start_point: Vector2i
var map: Map
var path: Array[Vector2i]


func draw_path(from: Vector2i, to: Vector2i, unit_type: StringName, passable_tiles: Array[Vector2i]) -> void:
	_remove_sprites()
	path = _a_star(from, to, unit_type, passable_tiles)
	if (path.size() > 1):
		for i in path.size():
			var start_tile: bool = i == 0
			var end_tile: bool = i + 1 >= path.size()
			var tile: Vector2i = path[i]
			
			var region: Vector2i = Vector2i(0,0)
			
			var next_tile: Vector2i = Vector2i(0,0)
			var last_tile: Vector2i = Vector2i(0,0)
			if (not end_tile):
				next_tile = path[i+1]
			if (not start_tile):
				last_tile = path[i-1]
			var next_diff: Vector2i = next_tile-tile
			var last_diff: Vector2i = last_tile-tile
			if (start_tile):
				region = START_POINTS[next_diff]
			elif (end_tile):
				region = END_POINTS[last_diff]
			elif (next_diff.x == 0 and last_diff.x == 0):
				region = UD_POINT
			elif (next_diff.y == 0 and last_diff.y == 0):
				region = LR_POINT
			elif (next_diff in CORNER_POINTS):
				if (last_diff in CORNER_POINTS[next_diff]):
					region = CORNER_POINTS[next_diff][last_diff]
			
			_add_sprite(tile, region)
	


func clear_arrows() -> void:
	_start_point = Vector2i(0,0)
	_remove_sprites()

func _remove_sprites() -> void:
	path = []
	for child in get_children():
		child.queue_free()
		remove_child(child)

func _a_star(start: Vector2i, goal: Vector2i, unit_type: StringName, passable_tiles: Array[Vector2i]) -> Array[Vector2i]:
	var queue: PriorityQueue = PriorityQueue.new()
	var path_map: Dictionary = {}
	var g_scores: Dictionary = {}
	
	queue.insert(start, 0)
	g_scores[start] = 0
	
	while not queue.is_empty():
		var current = queue.pop_lowest()
		if (current == goal):
			return _get_path(path_map, current)
		if not current in g_scores:
			g_scores[current] = INF
		for n in VectorUtils.NEIGHBOURS:
			var neighbour: Vector2i = current+n
			if not neighbour in passable_tiles:
				continue
			if not neighbour in g_scores:
				g_scores[neighbour] = INF
			
				
			var new_g_score = g_scores[current] + map.get_tile_cost(neighbour, unit_type)
			if (new_g_score < g_scores[neighbour]):
				path_map[neighbour] = current
				g_scores[neighbour] = new_g_score
				queue.insert(neighbour, VectorUtils.manhattan_distance(neighbour,goal))
	
	return []

func _get_path(path_map: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = [current]
	while current in path_map.keys():
		current = path_map[current]
		out.push_front(current)
	return out

func _add_sprite(vector: Vector2i, region: Vector2i) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _arrow_texture
	sprite.centered = false
	sprite.position = vector*Map.TILE_SIZE
	sprite.region_enabled = true
	sprite.region_rect = Rect2i(region*Map.TILE_SIZE, Vector2i(Map.TILE_SIZE, Map.TILE_SIZE))
	add_child(sprite)
