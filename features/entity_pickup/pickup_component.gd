extends Area2D

var _is_held = false
var _mouse_hovered := false

func _on_mouse_entered():
	_mouse_hovered = true

func _on_mouse_exited():
	_mouse_hovered = false

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
