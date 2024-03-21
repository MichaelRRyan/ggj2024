extends Node

signal entity_clicked(entity : Entity)
signal entity_held(entity : Entity)
signal entity_released(entity : Entity)

enum CursorState {
	IDLE,
	PROCESSING,
	CLICK,
	HOLD,
}

var _state = CursorState.IDLE
var _hovered_interactables = []
var _held_entity : Entity = null

#-------------------------------------------------------------------------------
func _ready():
	Global.mouse.connect("interactable_entered", _on_interactable_entered)
	Global.mouse.connect("interactable_exited", _on_interactable_exited)

#-------------------------------------------------------------------------------
func _on_interactable_entered(node):
	_hovered_interactables.push_back(node)
	
#-------------------------------------------------------------------------------
func _on_interactable_exited(node):
	_hovered_interactables.erase(node)

#-------------------------------------------------------------------------------
# TODO Pickup with priority - See Global.Mouse comments.
func _find_hold_target():
	if _hovered_interactables.is_empty():
		return null
	
	var parent = _hovered_interactables.front().get_parent()
	if parent and parent is Entity:
		return parent

#-------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("select"):
		if _state == CursorState.IDLE:
			_set_state(CursorState.PROCESSING)
					
	elif event.is_action_released("select"):
		if _state == CursorState.PROCESSING:
			_set_state(CursorState.CLICK)
		elif _state == CursorState.HOLD:
			_set_state(CursorState.IDLE)

#-------------------------------------------------------------------------------
func _on_hold_timer_timeout():
	if _state == CursorState.PROCESSING:
		_set_state(CursorState.HOLD)
	
#-------------------------------------------------------------------------------
func _set_state(new_state : CursorState) -> bool:
	var success = false
	
	# Switch on current state
	match _state:
		CursorState.IDLE:
			success = true
			if new_state == CursorState.PROCESSING:
				_trans_idle_to_processing()
			
		CursorState.PROCESSING:
			success = true
			if new_state == CursorState.HOLD:
				_trans_processing_to_hold()
			elif new_state == CursorState.CLICK:
				_trans_processing_to_click()
			
		CursorState.CLICK:
			success = true
			
		CursorState.HOLD:
			success = true
			if new_state == CursorState.IDLE:
				_trans_hold_to_idle()
	
	if success:
		_state = new_state
	
	return success


#-------------------------------------------------------------------------------
func _trans_idle_to_processing():
	$HoldTimer.start()
	
	_held_entity = _find_hold_target()
	if _held_entity:
		print("Processing " + _held_entity.name)

#-------------------------------------------------------------------------------
func _trans_processing_to_click():
	if _held_entity:
		emit_signal("entity_clicked", _held_entity)
	
	$HoldTimer.stop()
	call_deferred("_set_state", CursorState.IDLE)
	_held_entity = null
	
	if _held_entity:
		print("Clicked + " + _held_entity.name)
	else:
		print("Clicked")

#-------------------------------------------------------------------------------
func _trans_processing_to_hold():
	if _held_entity:
		emit_signal("entity_held", _held_entity)
	
	if _held_entity:
		print("Holding " + _held_entity.name)
	
#-------------------------------------------------------------------------------
func _trans_hold_to_idle():
	if _held_entity:
		emit_signal("entity_released", _held_entity)
		print("Released + " + _held_entity.name)
		_held_entity = null
	else:
		print("Released")

#-------------------------------------------------------------------------------
