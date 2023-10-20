extends Node


const VOID: StringName = "tile_void"
const PLAINS: StringName = "tile_plains"
const TREES: StringName = "tile_trees"
const MOUNTAINS: StringName = "tile_mountains"
const STRONGHOLD: StringName = "tile_stronghold"
const WATER: StringName = "tile_water"
const HILLS: StringName = "tile_hills"
const POISON: StringName = "tile_poison"
const BRIDGE: StringName = "tile_bridge"
const FORT: StringName = "tile_fort"

const ALL: Array[StringName] = [
	PLAINS, TREES, MOUNTAINS, STRONGHOLD, WATER, HILLS, POISON, BRIDGE, FORT
]

const COST_MAX: int = 999999

const TILE_COSTS: Dictionary = {
	VOID: COST_MAX,
	PLAINS: 1,
	TREES: 2,
	MOUNTAINS: COST_MAX,
	STRONGHOLD: 1,
	WATER: COST_MAX,
	HILLS: 3,
	POISON: 2,
	BRIDGE: 1,
	FORT: 1
}

const TILE_NAMES: Dictionary = {
	VOID: "???",
	PLAINS: "Plains",
	TREES: "Trees",
	MOUNTAINS: "Mountains",
	STRONGHOLD: "Stronghold",
	WATER:"Water",
	HILLS:"Hills",
	POISON:"Sludge",
	BRIDGE:"Bridge",
	FORT:"Fort"
}

func get_tile_name(tile_type: StringName) -> String:
	if not tile_type in TILE_NAMES:
		tile_type = VOID
	return TILE_NAMES[tile_type]

func get_cost(tile_type: StringName, unit_type: int = UnitTypes.INFANTRY) -> int:
	var base_cost: int = COST_MAX
	if (tile_type == VOID):
		return COST_MAX
	if (tile_type in TILE_COSTS):
		base_cost = TILE_COSTS[tile_type]
	if (unit_type == UnitTypes.CAVALRY and base_cost > 1):
		base_cost *= 2
	elif (unit_type == UnitTypes.FLIER):
		base_cost = 1
	
	return base_cost
