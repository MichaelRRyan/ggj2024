extends Area2D
class_name PickupComponent

@export var _drag_speed := 10.0

enum HoldState { NOT_HELD, MOUSE_CURSOR, ENTITY }

var _held_state = HoldState.NOT_HELD
var _mouse_hovered := false
var _parent : CharacterBody2D = null
var _hovered_hold_component = null


#-------------------------------------------------------------------------------
func is_held():
	return _held_state != HoldState.NOT_HELD


#-------------------------------------------------------------------------------
func mouse_pickup():
	_held_state = HoldState.MOUSE_CURSOR
	print(_parent.name + " Held mouse")

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
	if _held_state == HoldState.MOUSE_CURSOR:
		var distance = get_global_mouse_position() - _parent.position
		var raw_vel = distance * _drag_speed
		var distance_with_framerate = distance.length() * 60.0
		var vel_length = clamp(raw_vel.length(), -distance_with_framerate, distance_with_framerate)
		var final_vel = raw_vel.normalized() * vel_length
		_parent.velocity = final_vel
		
	elif _held_state == HoldState.ENTITY:
		_parent.position = _hovered_hold_component.global_position

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
			
	elif event.is_action_released("select") and _held_state == HoldState.MOUSE_CURSOR:
		print("Unclick")
		if _hovered_hold_component: # If hovering over a hold component.
			Global.mouse.is_holding_entity = false
			_held_state = HoldState.ENTITY
			print(_parent.name + " Is held by entity")
		else:
			Global.mouse.is_holding_entity = false
			_held_state = HoldState.NOT_HELD
			print(_parent.name + " dropped")
			print(_parent.velocity)

#-------------------------------------------------------------------------------
func _on_area_entered(area):
	if area.is_in_group("hold_entity_component"):
		# If the previous hovered is not a minion and the new hovered is a minion, don't overwrite.
		if _hovered_hold_component \
				and area.get_parent().is_in_group("minion") \
				and not _hovered_hold_component.get_parent().is_in_group("minion"):
			return
			
		_hovered_hold_component = area
		print("Hold area entered")

#-------------------------------------------------------------------------------
func _on_area_exited(area):
	if area.is_in_group("hold_entity_component") \
			and area == _hovered_hold_component \
			and _held_state != HoldState.ENTITY:
		_hovered_hold_component = null
		print("Hold area exited")

#-------------------------------------------------------------------------------
