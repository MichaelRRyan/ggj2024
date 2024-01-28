extends Area2D
class_name PickupComponent

signal picked_up

@export var _drag_speed := 10.0

var _is_held = false
var _mouse_hovered := false
var _parent : CharacterBody2D = null
var _hovered_hold_component = null


#-------------------------------------------------------------------------------
func is_held():
	return _is_held


#-------------------------------------------------------------------------------
func mouse_pickup():
	_is_held = true
	emit_signal("picked_up")


#-------------------------------------------------------------------------------
func _ready():
	var parent = get_parent()
	if parent is CharacterBody2D:
		_parent = parent
	else:
		queue_free() # Remove this component from the scene, it won't work.
		print_debug("Pickup component doesn't have a CharacterBody2D parent, removing from scene...")


#-------------------------------------------------------------------------------
func _process(_delta):
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
		Global.mouse.request_pickup(self)
		
	elif event.is_action_released("select") and _is_held:
		# If hovering over a hold component and not a minion.
		if _hovered_hold_component and not _parent.is_in_group("minion"):
			Global.mouse.is_holding_entity = false
			_hovered_hold_component.hold(_parent, self)
			_is_held = false
			
		else:
			Global.mouse.is_holding_entity = false
			_is_held = false

#-------------------------------------------------------------------------------
func _on_area_entered(area):
	if area.is_in_group("hold_entity_component") and area.get_parent() != _parent:
		# If the previous hovered is not a minion and the new hovered is a minion, don't overwrite.
		if _hovered_hold_component \
				and area.get_parent().is_in_group("minion") \
				and not _hovered_hold_component.get_parent().is_in_group("minion"):
			return
			
		_hovered_hold_component = area

#-------------------------------------------------------------------------------
func _on_area_exited(area):
	if area.is_in_group("hold_entity_component") and area == _hovered_hold_component:
		_hovered_hold_component = null

#-------------------------------------------------------------------------------
func _on_tree_exiting():
	if _is_held:
		Global.mouse.is_holding_entity = false

#-------------------------------------------------------------------------------
