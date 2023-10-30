extends Camera2D
class_name BattleCamera

const SHAKE_AMOUNT: int = 8


var hits: int

func trigger_screen_shake(p_hits:int) -> void:
	hits = p_hits

func _process(_delta):
	if (hits > 0):
		hits -= 1
		var rad = randf()*2*PI
		offset = Vector2(cos(rad), sin(rad))*SHAKE_AMOUNT
	else:
		offset = Vector2(0,0)


