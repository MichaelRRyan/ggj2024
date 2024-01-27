extends Area2D

var _held_entity : Entity = null


func get_held_entity():
	return _held_entity

func hold(entity : Entity, pickup_component):
	_held_entity = entity
	pickup_component.connect("picked_up", drop)
	
func drop():
	_held_entity = null
	
func _process(delta):
	if _held_entity:
		_held_entity.position = global_position
