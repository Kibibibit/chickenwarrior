extends TileMap
class_name Map

const TILE_SIZE: int = 32

@onready
var _unit_parent = $Units

var _grid_lines: MapGridLines

func _ready() -> void:
	_grid_lines = MapGridLines.new(get_used_rect())
	add_child(_grid_lines)

func map_rect() -> Rect2i:
	return get_used_rect()

func get_units() -> Array[Unit]:
	var out: Array[Unit] = []
	for node in _unit_parent.get_children():
		if (node is Unit):
			out.append(node)
	return out

func get_maptileset() -> MapTileSet:
	assert(tile_set is MapTileSet, "Tile set must be MapTileSet")
	return tile_set

func get_tile_name(tile: Vector2i) -> String:
	return TileTypes.get_tile_name(get_tile_type(tile))

func get_tile_type(tile: Vector2i) -> StringName:
	if (get_used_rect().has_point(tile)):
		return get_maptileset().get_tile_type(get_cell_atlas_coords(0, tile))
	else:
		return TileTypes.VOID

func get_tile_cost(tile: Vector2i, unit_type: int = UnitTypes.INFANTRY) -> int:
	return TileTypes.get_cost(get_tile_type(tile), unit_type)
