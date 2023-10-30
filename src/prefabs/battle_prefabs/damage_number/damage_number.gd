extends Control
class_name DamageNumber

const _RESOURCE: PackedScene = preload("res://src/prefabs/battle_prefabs/damage_number/damage_number.tscn")


var _damage: int
var _crit: bool
var _miss: bool

@onready
var label: Label = $Label
@onready
var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	
	if (_miss):
		label.text = "MISS"
	else:
		if (_crit):
			label.add_theme_color_override("font_color", Color.RED)
		label.text = "%s" % _damage
	animation_player.play("damage_number_animations/damage_number_rise_animation")

static func create(damage: int, crit: bool, miss: bool) -> DamageNumber:
	var out: DamageNumber = _RESOURCE.instantiate()
	out._damage = damage
	out._crit = crit
	out._miss = miss
	return out



func on_finish_animation() -> void:
	get_parent().remove_child(self)
	queue_free()
