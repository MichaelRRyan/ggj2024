extends Node

enum CursorState {
	IDLE,
	PROCESSING,
	CLICK,
	HOLD,
}

var _state = CursorState.IDLE
var _hovered_interactables = []

#-------------------------------------------------------------------------------
func _ready():
	Global.mouse.connect("interactable_entered", _on_interactable_entered)
	Global.mouse.connect("interactable_exited", _on_interactable_exited)

#-------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("select"):
		if _state == CursorState.IDLE:
			_state = CursorState.PROCESSING
			$HoldTimer.start()
			
			if not _hovered_interactables.is_empty():
				var parent = _hovered_interactables.front().get_parent()
				if parent:
					print("Clicked " + parent.name)
					
	elif event.is_action_released("select"):
		if _state == CursorState.HOLD or _state == CursorState.CLICK:
			_state = CursorState.IDLE
			print("Released")
			
			if _state == CursorState.CLICK:
				$HoldTimer.stop()

#-------------------------------------------------------------------------------
func _on_hold_timer_timeout():
	if _state == CursorState.PROCESSING:
		_state == CursorState.HOLD
	
	elif _state == CursorState.IDLE:
		_state == CursorState.CLICK
	
	if not _hovered_interactables.is_empty():
		print("Holding " + _hovered_interactables.front().name)

#-------------------------------------------------------------------------------
func _on_interactable_entered(node):
	_hovered_interactables.push_back(node)
	
#-------------------------------------------------------------------------------
func _on_interactable_exited(node):
	_hovered_interactables.erase(node)
	
#-------------------------------------------------------------------------------
func _set_state(new_state : CursorState) -> bool:
	var success = false
	
	match new_state:
		CursorState.IDLE:
			success = true
			
		CursorState.PROCESSING:
			if _state == CursorState.IDLE:
				$HoldTimer.start()
			
			success = true
			
		CursorState.CLICK:
			success = true
			
		CursorState.HOLD:
			success = true
	
	if success:
		_state = new_state
	
	return success

#-------------------------------------------------------------------------------
