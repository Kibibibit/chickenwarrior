extends Panel
class_name AttackPanel

@onready var title: Label = $MainVBox/AttackTitleLabel
@onready var player_unit_display: UnitDisplay = $MainVBox/HBoxContainer/PlayerUnitDisplay
@onready var enemy_unit_display: UnitDisplay = $MainVBox/HBoxContainer/EnemyUnitDisplay
@onready var stats_panel: AttackStatsPanel = $MainVBox/AttackStatsPanel


func show_attack(player_unit: Unit, enemy_unit: Unit) -> void:
	
	
	
	var distance: float = (abs(player_unit.position.x - enemy_unit.position.x) + abs(player_unit.position.y - enemy_unit.position.y)) / float(Map.TILE_SIZE)
	var player_weapon: Weapon = player_unit.get_equipped_weapon()
	var enemy_weapon: Weapon = enemy_unit.get_equipped_weapon()
	var player_min_range: int = 1
	var enemy_min_range: int = 1
	var player_max_range: int = 1
	var enemy_max_range: int = 1
	if (player_weapon != null):
		player_min_range = player_weapon.min_range
		player_max_range = player_weapon.max_range
	if (enemy_weapon != null):
		enemy_min_range = enemy_weapon.min_range
		enemy_max_range = enemy_weapon.max_range
		
	
	
	var player_in_range: bool = player_min_range <= distance and distance <= player_max_range
	var enemy_in_range: bool = enemy_min_range <= distance and distance <= enemy_max_range

	
	var enemy_lost_health: int = 0 if not player_in_range else player_unit.get_predicted_damage(enemy_unit)
	var player_lost_health: int = 0 if not enemy_in_range else enemy_unit.get_predicted_damage(player_unit)
	player_unit_display.show_unit(player_unit, player_lost_health)
	enemy_unit_display.show_unit(enemy_unit, enemy_lost_health)
	stats_panel.show_units(player_unit, enemy_unit, player_in_range, enemy_in_range)
	
	title.text = "%s vs %s" % [player_unit.character.name, enemy_unit.character.name]
	visible = true

func hide_attack() -> void:
	player_unit_display.hide_unit()
	enemy_unit_display.hide_unit()
	stats_panel.hide_units()
	visible = false
