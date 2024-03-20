extends Node

# Picks up objects and minions. Always picks up objects before minions.
class Mouse:
	signal interactable_entered(node)
	signal interactable_exited(node)
	
	var is_holding_entity = false
	var _requested_pickup = []
	
	# Opposed to first come first served, the mouse collects requests for a frame,
	# then tries to pickup objects before minions.
	func request_pickup(node : Node2D):
		if not is_holding_entity:
			_requested_pickup.append(node)
			call_deferred("_pickup")
		
	func _pickup():
		if _requested_pickup.is_empty(): return
		
		# Looks for a request that's not a minion.
		for object in _requested_pickup:
			if not object.get_parent().is_in_group("minion"):
				object.mouse_pickup()
				is_holding_entity = true
				_requested_pickup.clear()
				return
		
		# Falls back to whatever is at the front of the list.
		_requested_pickup.front().mouse_pickup()
		is_holding_entity = true
		_requested_pickup.clear()
	
	func entered(node):
		emit_signal("interactable_entered", node)
	
	func exited(node):
		emit_signal("interactable_exited", node)


var mouse : Mouse = Mouse.new()

var minion_names = [
	"Anastasia",
	"Aaron",
	"Abeer",
	"Adrian",
	"Áine",
	"Alex",
	"Ben",
	"Noel",
	"Caroline",
	"Conor",
	"Darragh",
	"David",
	"Adam",
	"Elisabeth",
	"Emily",
	"Emma",
	"Mathias",
	"Milo",
	"Ian",
	"Jack",
	"Jad",
	"Joshua",
	"Julianna",
	"Katrina",
	"Libor",
	"Martin",
	"Masih",
	"Matěj",
	"Michael",
	"Monika",
	"Nicholas",
	"Naoise",
	"Pavel",
	"Pete",
	"Rachel",
	"Robert",
	"David",
	"Luke",
	"Tymek",
	"Veronika",
	"Jordan",
	"Wiktoria",
	"Olawole"
]
