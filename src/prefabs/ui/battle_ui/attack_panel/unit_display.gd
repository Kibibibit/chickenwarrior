extends Panel
class_name UnitDisplay


@onready
var unit_shader: ShaderMaterial = preload("res://resources/materials/unit_shader/unit_shader_material.tres").duplicate()
@onready
var unit_sprite: AnimatedSprite2D = $MainVBox/HBoxContainer2/AspectRatioContainer/UnitSprite
@onready
var health_bar: ColorRect = $MainVBox/HealthBar
@onready
var weapon_icon: TextureRect = $MainVBox/HBoxContainer/WeaponIcon
@onready
var weapon_name: Label = $MainVBox/HBoxContainer/WeaponLabel

var _d: float = 0.0


func _ready():
	unit_sprite.material = unit_shader
	health_bar.material = health_bar.material.duplicate()
	health_bar.material.set_shader_parameter("width", health_bar.custom_minimum_size.x)
	health_bar.material.set_shader_parameter("height", health_bar.custom_minimum_size.y)
	health_bar.material.set_shader_parameter("no_health_color", Color.WEB_MAROON)
	health_bar.material.set_shader_parameter("full_health_color", Color.WEB_MAROON)


func show_unit(unit: Unit, lost_health: int) -> void:
	unit_sprite.material.set_shader_parameter('player', unit.team)
	health_bar.material.set_shader_parameter("health", float(unit.hp) / float(unit.get_max_hp()))
	health_bar.material.set_shader_parameter("lost_health", float(lost_health) / float(unit.get_max_hp()))
	var weapon: Weapon = unit.get_equipped_weapon()
	if (weapon != null):
		weapon_icon.visible = true
		weapon_icon.texture = weapon.icon
		weapon_name.text = weapon.name
	else:
		weapon_icon.visible = false
		weapon_name.text = "Unarmed"
	visible = true

func _process(delta):
	_d = wrapf(_d+(delta*4.0), 0.0, 2*PI)
	health_bar.material.set_shader_parameter("delta", (0.3*sin(_d)) + 0.5)


func hide_unit() -> void:
	visible = false
