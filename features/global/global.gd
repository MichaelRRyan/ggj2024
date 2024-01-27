extends Node

class Mouse:
	var is_holding_entity = false
	var _requested_pickup = []
	
	func request_pickup(node : Node2D):
		if not is_holding_entity:
			_requested_pickup.append(node)
			call_deferred("_pickup")
		
	func _pickup():
		if _requested_pickup.is_empty(): return
		
		for object in _requested_pickup:
			if not object.get_parent().is_in_group("minion"):
				object.mouse_pickup()
				is_holding_entity = true
				_requested_pickup.clear()
				return
		
		_requested_pickup.front().mouse_pickup()
		is_holding_entity = true
		_requested_pickup.clear()


var mouse : Mouse = Mouse.new()

var minion_names = [
	"Joe",
	"Pete",
	"John",
	"Michael",
	"Nick",
	"Naoise",
	"Dylan",
	"Matt"
]
