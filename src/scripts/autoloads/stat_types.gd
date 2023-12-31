extends Node


const HP: StringName = "stat_hp"
const STRENGTH: StringName = "stat_strength"
const MAGIC: StringName = "stat_magic"
const DEXTERITY: StringName = "stat_dexterity"
const SPEED: StringName = "stat_speed"
const LUCK: StringName = "stat_luck"
const DEFENCE: StringName = "stat_defence"
const RESISTANCE: StringName = "stat_resistance"


const ABBREVIATION: Dictionary = {
	HP: "hp",
	STRENGTH: "str",
	MAGIC: "mag",
	DEXTERITY: "dex",
	SPEED:"spd",
	LUCK:"lck",
	DEFENCE:"def",
	RESISTANCE:"res"
}


const ALL: Array[StringName] = [
	HP, STRENGTH, MAGIC, DEXTERITY, SPEED, LUCK, DEFENCE, RESISTANCE
]
