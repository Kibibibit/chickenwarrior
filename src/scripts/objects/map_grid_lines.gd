extends Sprite2D
class_name MapGridLines


var _grid_texture: CompressedTexture2D = preload("res://assets/grid_lines.png")
var _transparent_material: ShaderMaterial = preload("res://resources/materials/transparent/transparent_material.tres")

var opacity: float = 0.1 : set = _set_opacity

func _init(map_rect: Rect2i) -> void:
	centered = false
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	region_enabled = true
	region_rect = Rect2(map_rect.position*Map.TILE_SIZE, map_rect.size*Map.TILE_SIZE)
	texture = _grid_texture
	material = _transparent_material
	_set_opacity(opacity)

func _set_opacity(p_opacity:float) -> void:
	opacity = p_opacity
	material.set_shader_parameter("opacity", p_opacity)
