extends TileSet
class_name MapTileSet

@export
var tile_dictionary: Dictionary

@export
var tile_map_texture: Texture2D

var _mappings: Dictionary = {}
var _color_mappings: Dictionary = {}

func get_tile_type(atlas_coords: Vector2i) -> StringName:
	if (atlas_coords in _mappings):
		return _mappings[atlas_coords]
	else:
		return _get_tile_mapping(atlas_coords)


func _get_tile_mapping(atlas_coords) -> StringName:
	var tile_type: StringName = TileTypes.VOID
	if (_color_mappings.is_empty()):
		_create_color_mappings()
	if (
		atlas_coords.x >= 0 and 
		atlas_coords.x < tile_map_texture.get_width() and
		atlas_coords.y >= 0 and
		atlas_coords.y < tile_map_texture.get_height()-1
	):
		var pixel: int = tile_map_texture.get_image().get_pixelv(atlas_coords+Vector2i(0,1)).to_abgr32()
		if (pixel in _color_mappings):
			tile_type = _color_mappings[pixel]
	_mappings[atlas_coords] = tile_type
	return tile_type

func _create_color_mappings() -> void:
	for i in TileTypes.ALL.size():
		var tile_type: StringName = TileTypes.ALL[i]
		var pixel: int = tile_map_texture.get_image().get_pixel(i, 0).to_abgr32()
		_color_mappings[pixel] = tile_type
