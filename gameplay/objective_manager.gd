extends Node

var _num_minions = 0


func _ready():
	var minions = get_tree().get_nodes_in_group("minion")
	_num_minions = minions.size()
	for node in minions:
		var minion = node as Minion
		minion.connect("died", _minion_died)

func _minion_died():
	_num_minions -= 1
	if _num_minions <= 0:
		print("Lost game")
