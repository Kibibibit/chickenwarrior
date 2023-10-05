@icon("res://assets/icons/item.png")
extends Resource
class_name Item

@export var name: String
@export var breakable: bool = true
@export var max_uses: int
var uses: int = max_uses
