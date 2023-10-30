extends Control
class_name DamageNumber

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

func init(damage: int, crit: bool, miss: bool) -> void:
	_damage = damage
	_crit = crit
	_miss = miss


func on_finish_animation() -> void:
	get_parent().remove_child(self)
	queue_free()
