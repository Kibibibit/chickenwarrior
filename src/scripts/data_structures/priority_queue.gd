extends RefCounted
class_name PriorityQueue


var _data: Dictionary


func _init() -> void:
	_data = {}


func insert(item: Variant, priority: int) -> void:
	_data[item] = priority


func pop_lowest() -> Variant:
	if (_data.is_empty()):
		return null
	var min_priority: int = 0
	var started: bool = false
	var out: Variant
	
	for item in _data:
		if (not started or _data[item] < min_priority):
			min_priority = _data[item]
			started = true
			out = item
	_data.erase(out)
	return out

func contains(item: Variant) -> bool:
	return item in _data.keys()

func is_empty() -> bool:
	return _data.is_empty()
