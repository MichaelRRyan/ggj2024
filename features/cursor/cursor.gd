extends Node

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
func _input(event):
	if event.is_action_pressed("select"):
		if _state == CursorState.IDLE:
			_set_state(CursorState.PROCESSING)
					
	elif event.is_action_released("select"):
		if _state == CursorState.HOLD or _state == CursorState.CLICK:
			_state = CursorState.IDLE
			print("Released")
			
			if _state == CursorState.CLICK:
				$HoldTimer.stop()

#-------------------------------------------------------------------------------
func _on_hold_timer_timeout():
	if _state == CursorState.PROCESSING:
		_set_state(CursorState.HOLD)
	elif _state == CursorState.IDLE:
		_set_state(CursorState.CLICK)

#-------------------------------------------------------------------------------
func _on_interactable_entered(node):
	_hovered_interactables.push_back(node)
	
#-------------------------------------------------------------------------------
func _on_interactable_exited(node):
	_hovered_interactables.erase(node)
	
#-------------------------------------------------------------------------------
func _set_state(new_state : CursorState) -> bool:
	var success = false
	
	# Switch on current state
	match _state:
		CursorState.IDLE:
			success = true
			
			# Transition from IDLE to PROCESSING
			if new_state == CursorState.PROCESSING:
				_trans_idle_to_processing()
				
			# Transition from IDLE to PROCESSING
			if new_state == CursorState.CLICK:
				
				if not _hovered_interactables.is_empty():
					var parent = _hovered_interactables.front().get_parent()
					
					if parent and parent is Entity:
						_held_entity = parent
						print("Clicked " + _held_entity.name)
			
		CursorState.PROCESSING:
			success = true
			
			# Transition to HOLD
			if _state == CursorState.HOLD:
				if not _hovered_interactables.is_empty():
					print("Holding " + _hovered_interactables.front().name)
			
			# Transition to CLICK
			if new_state == CursorState.CLICK:
				if _held_entity:
					print("Clicked + " + _held_entity.name)
				else:
					print("Clicked")
			
		CursorState.CLICK:
			success = true
			
		CursorState.HOLD:
			success = true
	
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
# TODO Pickup with priority - See Global.Mouse comments.
func _find_hold_target():
	if _hovered_interactables.is_empty():
		return null
	
	var parent = _hovered_interactables.front().get_parent()
	if parent and parent is Minion: # TODO switch for interface
		return parent
