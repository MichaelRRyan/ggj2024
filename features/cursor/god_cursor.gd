extends "res://features/cursor/cursor.gd"


#-------------------------------------------------------------------------------
func _on_entity_clicked(entity):
	if entity is Minion:
		var minion : Minion = entity
		minion.change_state_to(Minion.MinionState.WORSHIP)


#-------------------------------------------------------------------------------
func _on_entity_held(entity):
	pass # Replace with function body.


#-------------------------------------------------------------------------------
func _on_entity_released(entity):
	pass # Replace with function body.

#-------------------------------------------------------------------------------
