extends Node


func rnn(hit_chance: int, n:int) -> bool:
	if (hit_chance <= 0):
		return false
	if (hit_chance >= 100):
		return true
		
	var roll: float = 0
	for i in n:
		roll += float(randi_range(0,99))
	
	if (n > 1):
		roll /= float(n)
	return roll <= hit_chance
	

func rn1(hit_chance: int) -> bool:
	return rnn(hit_chance,1)

func rn2(hit_chance: int) -> bool:
	return rnn(hit_chance, 2)
