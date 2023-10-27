extends Panel
class_name AttackStatsPanel



@onready var player_attack_label: Label = $MainHBox/MainGrid/PlayerAttack
@onready var enemy_attack_label: Label = $MainHBox/MainGrid/EnemyAttack
@onready var player_hit_label: Label = $MainHBox/MainGrid/PlayerHit
@onready var enemy_hit_label: Label = $MainHBox/MainGrid/EnemyHit
@onready var player_crit_label: Label = $MainHBox/MainGrid/PlayerCrit
@onready var enemy_crit_label: Label = $MainHBox/MainGrid/EnemyCrit



func show_units(player_unit: Unit, enemy_unit: Unit, player_in_range: bool, enemy_in_range: bool) -> void:
	
	var player_damage: int = -1 if not player_in_range else player_unit.get_damage_per_attack(enemy_unit)
	var enemy_damage: int = -1 if not enemy_in_range else enemy_unit.get_damage_per_attack(player_unit)
	var player_count:int = 0 if not player_in_range else player_unit.get_attack_count(enemy_unit)
	var enemy_count:int = 0 if not enemy_in_range else enemy_unit.get_attack_count(player_unit)
	var player_hit:int = -1 if not player_in_range else player_unit.get_hit_chance(enemy_unit)
	var enemy_hit:int = -1 if not enemy_in_range else enemy_unit.get_hit_chance(player_unit)
	var player_crit:int = -1 if not player_in_range else player_unit.get_crit_chance(enemy_unit)
	var enemy_crit:int = -1 if not enemy_in_range else enemy_unit.get_crit_chance(player_unit)
	
	if (player_damage >= 0):
		player_attack_label.text = "%s" % player_damage
	else:
		player_attack_label.text = "-"
	if (player_count > 1):
		player_attack_label.text = "%s x%s" % [player_attack_label.text, player_count]
	
	if (enemy_damage >= 0):
		enemy_attack_label.text = "%s" % enemy_damage
	else:
		enemy_attack_label.text = "-"
	if (enemy_count > 1):
		enemy_attack_label.text = "%s x%s" % [enemy_attack_label.text, enemy_count]
	
	if (player_crit >= 0):
		player_crit_label.text = "%s%%" % player_crit
	else:
		player_crit_label.text = "-"
	if (enemy_crit >= 0):
		enemy_crit_label.text = "%s%%" % enemy_crit
	else:
		enemy_crit_label.text = "-"
	
	if (player_hit >= 0):
		player_hit_label.text = "%s%%" % player_hit
	else:
		player_hit_label.text = "-"
	
	if (enemy_hit >= 0):
		enemy_hit_label.text = "%s%%" % enemy_hit
	else:
		enemy_hit_label.text = "-"
	
	visible = true

func hide_units() -> void:
	visible = false
