extends Panel
class_name AttackStatsPanel



@onready var player_attack_label: Label = $MainHBox/MainGrid/PlayerAttack
@onready var enemy_attack_label: Label = $MainHBox/MainGrid/EnemyAttack
@onready var player_hit_label: Label = $MainHBox/MainGrid/PlayerHit
@onready var enemy_hit_label: Label = $MainHBox/MainGrid/EnemyHit
@onready var player_crit_label: Label = $MainHBox/MainGrid/PlayerCrit
@onready var enemy_crit_label: Label = $MainHBox/MainGrid/EnemyCrit



func show_units(player_unit: Unit, enemy_unit: Unit) -> void:
	
	var player_damage: int = player_unit.get_damage_per_attack(enemy_unit)
	var enemy_damage: int = enemy_unit.get_damage_per_attack(player_unit)
	var player_count: int = player_unit.get_attack_count(enemy_unit)
	var enemy_count: int = enemy_unit.get_attack_count(player_unit)
	var player_hit: int = player_unit.get_hit_chance(enemy_unit)
	var enemy_hit: int = enemy_unit.get_hit_chance(player_unit)
	var player_crit: int = player_unit.get_crit_chance(enemy_unit)
	var enemy_crit: int = enemy_unit.get_crit_chance(player_unit)
	
	player_attack_label.text = "%s" % player_damage
	if (player_count > 1):
		player_attack_label.text = "%s x%s" % [player_attack_label.text, player_count]
	
	enemy_attack_label.text = "%s" % enemy_damage
	if (enemy_count > 1):
		enemy_attack_label.text = "%s x%s" % [enemy_attack_label.text, enemy_count]
	
	player_crit_label.text = "%s%%" % player_crit
	enemy_crit_label.text = "%s%%" % enemy_crit
	
	player_hit_label.text = "%s%%" % player_hit
	enemy_hit_label.text = "%s%%" % enemy_hit
	
	visible = true

func hide_units() -> void:
	visible = false
