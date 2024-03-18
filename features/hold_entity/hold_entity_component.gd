extends Area2D

signal entity_held(entity_type : int)
signal entity_dropped(entity_type : int)

var _held_entity : Entity = null


func get_held_entity():
	return _held_entity

func hold(entity : Entity, pickup_component):
	_held_entity = entity
	pickup_component.connect("picked_up", drop)
	emit_signal("entity_held", _held_entity.get_type())
	
	if _held_entity.get_type() == Entity.EntityType.TOOL:
		_held_entity.get_node("Sprite2D").hide()
	
func drop():
	if _held_entity:
		emit_signal("entity_dropped", _held_entity.get_type())
		_held_entity.get_node("Sprite2D").show()
		_held_entity = null
	
func _process(_delta):
	if _held_entity:
		_held_entity.position = global_position

func _on_tree_exiting():
	drop()
