extends Area2D

@export var _drag_speed := 10.0

var _is_held = false
var _mouse_hovered := false
var _parent : CharacterBody2D = null


#-------------------------------------------------------------------------------
func _ready():
	var parent = get_parent()
	if parent is CharacterBody2D:
		_parent = parent
	else:
		queue_free() # Remove this component from the scene, it won't work.
		print_debug("Pickup component doesn't have a CharacterBody2D parent, removing from scene...")


#-------------------------------------------------------------------------------
func _process(delta):
	if _is_held:
		var distance = get_global_mouse_position() - _parent.position
		var raw_vel = distance * _drag_speed
		var distance_with_framerate = distance.length() * 60.0
		var vel_length = clamp(raw_vel.length(), -distance_with_framerate, distance_with_framerate)
		var final_vel = raw_vel.normalized() * vel_length
		_parent.velocity = final_vel

#-------------------------------------------------------------------------------
func _on_mouse_entered():
	_mouse_hovered = true

#-------------------------------------------------------------------------------
func _on_mouse_exited():
	_mouse_hovered = false

#-------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("select") and _mouse_hovered:
		if not Global.mouse.is_holding_entity:
			Global.mouse.is_holding_entity = true
			_is_held = true
			print("held")
			
	elif event.is_action_released("select") and _is_held:
		Global.mouse.is_holding_entity = false
		_is_held = false
		print("dropped")
		print(_parent.velocity)

#-------------------------------------------------------------------------------
