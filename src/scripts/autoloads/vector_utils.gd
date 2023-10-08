extends Node

const NEIGHBOURS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]


func manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x-b.x) + abs(a.y-b.y)
