extends Node2D

@export var _drag_speed := 10.0

var _held_entity = null

#-------------------------------------------------------------------------------
func _on_cursor_entity_clicked(entity : Entity) -> void:
	if entity is Minion:
		var minion : Minion = entity
		minion.change_state_to(Minion.MinionState.WORSHIP)

#-------------------------------------------------------------------------------
func _on_cursor_entity_held(entity : Entity) -> void:
	if entity is Minion:
		var minion : Minion = entity
		minion.change_state_to(Minion.MinionState.PICKED_UP)
	
	_held_entity = entity
	_held_entity.connect("tree_exited", _entity_tree_exited)

#-------------------------------------------------------------------------------
func _on_cursor_entity_released(entity : Entity) -> void:
	if entity is Minion:
		var minion : Minion = entity
		minion.change_state_to(Minion.MinionState.IDLE)
	
	entity.disconnect("tree_exited", _entity_tree_exited)
	_held_entity = null

#-------------------------------------------------------------------------------
func _physics_process(_delta):
	if _held_entity:
		var distance = get_global_mouse_position() - _held_entity.position
		var raw_vel = distance * _drag_speed
		var distance_with_framerate = distance.length() * 60.0
		var vel_length = clamp(raw_vel.length(), -distance_with_framerate, distance_with_framerate)
		var final_vel = raw_vel.normalized() * vel_length
		_held_entity.velocity = final_vel

#-------------------------------------------------------------------------------
func _entity_tree_exited():
	_held_entity = null
	print_debug("Entity exited tree.")


#-------------------------------------------------------------------------------
