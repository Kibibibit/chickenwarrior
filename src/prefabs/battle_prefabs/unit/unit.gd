@icon("res://assets/icons/unit.png")
@tool
extends AnimatedSprite2D
class_name Unit

const ACTION_NONE: int = -1
const ACTION_ARMS: int = 0
const ACTION_ATTACK: int = 1
const ACTION_ASSIST: int = 2
const ACTION_ITEMS: int = 9
const ACTION_WAIT: int = 10

const ACTION_MAP: Dictionary = {
	ACTION_ARMS: "Arms",
	ACTION_ATTACK:"Attack",
	ACTION_ASSIST:"Assist",
	ACTION_ITEMS:"Items",
	ACTION_WAIT:"Wait"
}


const TEAM_PLAYER: int = 0
const TEAM_ENEMY: int = 1
const TEAM_ALLY: int = 2

const UNIT_MOVE_SPEED: int = 700

const _damage_number_scene: PackedScene = preload("res://src/prefabs/battle_prefabs/damage_number/damage_number.tscn")

signal move_finished
signal attack_hit(damage: int)


var attacking: bool = false
var attack_enemy_position: Vector2
@export_range(0,1.0)
var attack_animation_delta: float = 0.0
var attacking_original_position: Vector2
var attack_animation_damage: int = 0
var attack_animation_crit: bool = false
var attack_animation_miss: bool = false

@onready var h_bar: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var character: Character: set = _set_character
@export_enum("Player", "Enemy", "Ally") var team: int: set = _set_team
@export var tile: Vector2i: set = _set_tile
@export var hp: int = 0
var moved: bool = false : set = _set_moved
var current_tile_type: StringName = TileTypes.VOID

var _path: Array[Vector2i] = []

func _set_character(p_character: Character) -> void:
	character = p_character
	if (Engine.is_editor_hint() and p_character != null):
		hp = character.get_max_hp()

func _set_tile(p_tile: Vector2i):
	tile = p_tile
	if (Engine.is_editor_hint()):
		position = tile*Map.TILE_SIZE

	

func _set_team(p_team: int) -> void:
	team = p_team
	material.set_shader_parameter("player", p_team)

func _set_moved(p_moved: bool) -> void:
	moved = p_moved
	material.set_shader_parameter("moved", p_moved)

func _ready() -> void:
	material = preload("res://resources/materials/unit_shader/unit_shader_material.tres").duplicate()
	material.set_shader_parameter("player", team)
	if (character != null):
		hp = character.get_max_hp()
		h_bar.material = h_bar.material.duplicate()
		h_bar.material.set_shader_parameter("health", float(hp)/float(get_max_hp()))

func highlight() -> void:
	play("highlight")

func unhighlight() -> void:
	play("default")

func get_unit_type() -> int:
	return character.get_unit_type()

func get_max_hp() -> int:
	return character.get_max_hp()

func path_to(path: Array[Vector2i]) -> void:
	_path = path.duplicate()

func equip_weapon(weapon: Weapon) -> void:
	character.equip_weapon(weapon)

func get_valid_actions(new_tile: Vector2i, attack_tiles: Array[Vector2i], unit_positions: Dictionary) -> Array[int]:
	var out: Array[int] = []
	if (_can_use_arms()):
		out.append(ACTION_ARMS)
	if (_can_attack(new_tile, attack_tiles, unit_positions)):
		out.append(ACTION_ATTACK)
	if (_can_assist()):
		out.append(ACTION_ASSIST)
	
	if (not character.inventory.is_empty()):
		out.append(ACTION_ITEMS)
	
	out.append(ACTION_WAIT)
	out.sort()
	return out

func get_equipped_weapon() -> Weapon:
	return character.get_equipped_weapon()

func get_weapon_ranges() -> Vector2i:
	return character.get_weapon_ranges()

func get_movement() -> int:
	return character.get_movement()

func _can_use_arms() -> bool:
	return false

func _can_attack(new_tile: Vector2i, attack_tiles: Array[Vector2i], unit_positions: Dictionary) -> bool:
	var ranges = get_weapon_ranges()
	var min_range = ranges.x
	var max_range = ranges.y
	for attack_tile in attack_tiles:
		var dist = VectorUtils.manhattan_distance(new_tile, attack_tile)
		if (attack_tile in unit_positions):
			if (min_range <= dist and dist <= max_range):
				var unit: Unit = instance_from_id(unit_positions[attack_tile])
				if (unit.team != team):
					return true
	return false
	
func _can_assist() -> bool:
	return false



func get_protection(weapon_base_stat: StringName) -> int:
	var stat: int = character.get_stat(weapon_base_stat)
	
	return stat + TileTypes.get_stat_bonus(current_tile_type, weapon_base_stat)

func get_damage_per_attack(enemy: Unit) -> int:
	var weapon: Weapon = get_equipped_weapon()
	var might: int = 0
	var base_stat_code: StringName = StatTypes.STRENGTH
	if (weapon != null):
		might = weapon.might
		base_stat_code = weapon.get_weapon_stat_code()
		if (weapon.has_type_bonus(enemy.get_unit_type())):
			might *= 3
	return might + character.get_stat(base_stat_code) - enemy.get_protection(base_stat_code)

func get_attack_speed() -> int:
	var weapon: Weapon = get_equipped_weapon()
	var weight: int = 0
	if (weapon != null):
		weight = weapon.weight
	var speed: int = character.get_stat(StatTypes.SPEED) 
	var strength: int = character.get_stat(StatTypes.STRENGTH)
	return speed - max(0,weight-floori(float(strength)/5.0))

func get_base_hit_chance() -> int:
	var weapon: Weapon = get_equipped_weapon()
	var hit_chance: int = 70
	var is_magic: bool = false
	var dex: int = character.get_stat(StatTypes.DEXTERITY)
	if (weapon != null):
		hit_chance = weapon.hit_chance
		is_magic = weapon.get_weapon_stat_code() == StatTypes.MAGIC
	if (is_magic):
		return hit_chance+ floori(float(dex+character.get_stat(StatTypes.LUCK))/2.0)
	else:
		return hit_chance+dex

func get_avoid_chance(enemy: Unit) -> int:
	var weapon: Weapon = enemy.get_equipped_weapon()
	var is_magic: bool = false
	if (weapon != null) :
		is_magic = weapon.get_weapon_stat_code() == StatTypes.MAGIC
	var out: int = 0
	if (is_magic):
		out = floori(float(character.get_stat(StatTypes.SPEED)+ character.get_stat(StatTypes.LUCK))/2.0)
	else:
		out = get_attack_speed()
	return out + TileTypes.get_stat_bonus(current_tile_type, TileTypes.AVOID_BONUS)

func get_hit_chance(enemy:Unit) -> int:
	return clampi(get_base_hit_chance()-enemy.get_avoid_chance(self), 0, 100)

func get_base_crit_chance() -> int:
	var crit: int = 0
	var weapon: Weapon = get_equipped_weapon()
	if (weapon != null):
		crit = weapon.crit_chance
	
	return crit + floori(float(character.get_stat(StatTypes.DEXTERITY)+ character.get_stat(StatTypes.LUCK))/2.0)

func get_crit_chance(enemy: Unit) -> int:
	return clampi(get_base_crit_chance() - enemy.character.get_stat(StatTypes.LUCK), 0, 100)


func get_weapon_attack_count() -> int:
	var weapon: Weapon = get_equipped_weapon()
	var hit_count: int = 1
	if (weapon != null):
		hit_count = weapon.attack_count
	return hit_count

func get_speed_attack_count(enemy: Unit) -> int:
	if (get_attack_speed() - enemy.get_attack_speed() >= 4):
		return 2
	return 1

func get_attack_total_count(enemy: Unit) -> int:
	var weapon_hit_count: int = get_weapon_attack_count()
	return weapon_hit_count * get_speed_attack_count(enemy)

func get_predicted_damage(enemy: Unit) -> int:
	return get_attack_total_count(enemy)*get_damage_per_attack(enemy)


func set_walk_animation(direction:Vector2i) -> void:
	var anim: StringName = "default"
	flip_h = false
	match direction:
		Vector2i.DOWN:
			anim = "walk_backwards"
		Vector2i.LEFT:
			anim = "walk_sideways"
		Vector2i.RIGHT:
			flip_h = true
			anim = "walk_sideways"
		Vector2i.UP:
			anim = "walk_forward"
	if (animation != anim):
		play(anim)

func _process(delta) -> void:
	
	if (!Engine.is_editor_hint()):
		var health_bar_value: float = h_bar.material.get_shader_parameter('health')
		health_bar_value = move_toward(health_bar_value, float(hp)/float(get_max_hp()), delta*10)
		h_bar.material.set_shader_parameter('health', clampf(health_bar_value, 0.0, 1.0))
		material.set_shader_parameter('outline_alpha', modulate.a)
	if (attacking):
		position = attacking_original_position.lerp(attack_enemy_position, attack_animation_delta)
	else:
		if (not _path.is_empty()):
			if position == Vector2(_path[0]*Map.TILE_SIZE):
				_path.remove_at(0)
			if (not _path.is_empty()):
				var next_pos = _path[0]*Map.TILE_SIZE
				var last_pos: Vector2 = position
				position.x = move_toward(position.x, next_pos.x, delta*UNIT_MOVE_SPEED)
				position.y = move_toward(position.y, next_pos.y, delta*UNIT_MOVE_SPEED)
				set_walk_animation(Vector2i((last_pos-position).normalized()))
			else:
				move_finished.emit()


static func get_action_label(action_code: int) -> String:
	if (action_code in ACTION_MAP):
		return ACTION_MAP[action_code]
	else:
		return "???"


func can_attack(enemy: Unit) -> bool:
	var distance: float = (abs(position.x - enemy.position.x) + abs(position.y - enemy.position.y)) / float(Map.TILE_SIZE)
	var weapon: Weapon = get_equipped_weapon()
	var min_range: int = 1
	var max_range: int = 1
	if (weapon != null):
		min_range = weapon.min_range
		max_range = weapon.max_range
	return min_range <= distance and distance <= max_range

func attack_animation(target:Vector2, damage: int, crit: bool, miss: bool) -> void:
	attacking = true
	attack_enemy_position = position+(target-position).normalized()*Map.TILE_SIZE
	attacking_original_position = position
	attack_animation_crit = crit and not miss
	attack_animation_damage = damage
	attack_animation_miss = miss

	
	if (crit and not miss):
		animation_player.play("attack/attack_crit")
	else:
		animation_player.play("attack/attack")
	
	await animation_player.animation_finished
	attacking = false

func display_attack_number() -> void:
	var damage_number: DamageNumber = _damage_number_scene.instantiate()
	damage_number.init(attack_animation_damage, attack_animation_crit, attack_animation_miss)
	
	if (not attack_animation_miss):
		attack_hit.emit(attack_animation_damage)
	get_parent().add_child(damage_number)
	damage_number.label.position = attack_enemy_position
	
func kill() -> void:
	if (!Engine.is_editor_hint()):
		animation_player.play("attack/death")
		await animation_player.animation_finished
		get_parent().remove_child(self)
		self.queue_free()
