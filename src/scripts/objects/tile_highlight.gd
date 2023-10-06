extends Node2D
class_name TileHighlight

const NEIGHBOURS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var map: Map
var _map_icons_texture: CompressedTexture2D = preload("res://assets/map_icons.png")
var _transparent_material: ShaderMaterial = preload("res://resources/materials/transparent/transparent_material.tres").duplicate()
var get_cost_callback: Callable

var _move_region: Rect2i = Rect2i(0,Map.TILE_SIZE,Map.TILE_SIZE, Map.TILE_SIZE)
var _attack_region: Rect2i = Rect2i(Map.TILE_SIZE*2,Map.TILE_SIZE,Map.TILE_SIZE, Map.TILE_SIZE)

func get_move_tiles(unit: Unit) -> Array[Vector2i]:
	var cost_map: Dictionary = {
		unit.tile: 0
	}
	var out: Array[Vector2i] = []
	var stack: Array[Vector2i] = [unit.tile]
	
	while (not stack.is_empty()):
		var current: Vector2i = stack.pop_front()
		var cost_to_current: int = cost_map[current]
		
		if (cost_to_current <= unit.character.movement):
			if (current != unit.tile and not current in out):
				out.append(current)
			for n in NEIGHBOURS:
				var neighbour: Vector2i = current+n
				if (map.get_used_rect().has_point(neighbour)):
					var cost: int = cost_to_current + map.get_tile_cost(neighbour, unit.get_unit_type())
					if (not neighbour in cost_map):
						cost_map[neighbour] = cost
						stack.push_back(neighbour)
					elif (cost_map[neighbour] > cost):
						cost_map[neighbour] = cost
						stack.push_back(neighbour)
	return out

func _flood_fill_attack(tile: Vector2i, min_range: int, max_range:int, explored:Array[Vector2i]) -> Array[Vector2i]:
	var distance_map: Dictionary = {tile: 0}
	var stack: Array[Vector2i] = [tile]
	var out: Array[Vector2i] = []
	
	while (not stack.is_empty()):
		var current: Vector2i = stack.pop_front()
		var distance_to_current = distance_map[current]
		if (distance_to_current <= max_range):
			if (
				distance_to_current >= min_range and 
				current != tile and 
				not current in out and 
				not current in explored
			):
				out.append(current)
			for n in NEIGHBOURS:
				var neighbour: Vector2i = current+n
				if (map.get_used_rect().has_point(neighbour)):
					var distance: int = distance_to_current + 1
					if (not neighbour in distance_map):
						distance_map[neighbour] = distance
						stack.push_back(neighbour)
					elif (distance_map[neighbour] > distance):
						distance_map[neighbour] = distance
						stack.push_back(neighbour)
	return out
		
func _add_sprite(tile: Vector2i, region: Rect2i) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _map_icons_texture
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.material = _transparent_material
	sprite.position = tile*Map.TILE_SIZE
	sprite.material.set_shader_parameter("opacity", 0.5)
	add_child(sprite)

func get_attack_tiles(unit: Unit, move_tiles: Array[Vector2i]) -> Array[Vector2i]:
	var min_range:int = -1
	var max_range:int = -1
	for item in unit.inventory:
		if (item is Weapon and unit.can_use(item)):
			if (item.min_range < min_range or min_range == -1):
				min_range = item.min_range
			if (item.max_range > max_range or max_range == -1):
				max_range = item.max_range
	var out: Array[Vector2i] = []
	var tiles: Array[Vector2i] = []
	tiles.append_array(move_tiles)
	tiles.append(unit.tile)
	for tile in tiles:
		var attack_tiles = _flood_fill_attack(tile, min_range, max_range, out)
		for t in attack_tiles:
			if (not t in out and t != unit.tile):
				out.append(t)
	
	return out

func highlight_tiles(move_tiles: Array[Vector2i], attack_tiles: Array[Vector2i]) -> void:
	for tile in move_tiles:
		_add_sprite(tile, _move_region)
	for tile in attack_tiles:
		if (not tile in move_tiles):
			_add_sprite(tile, _attack_region)

func clear_highlight() -> void:
	for child in get_children():
		child.queue_free()
		remove_child(child)

