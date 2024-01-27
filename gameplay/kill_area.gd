extends Area2D

#-------------------------------------------------------------------------------
func _on_body_entered(body):
	if body.is_in_group("minion") and body is Minion:
		var minion : Minion = body
		minion.take_damage(10000000)
		

#-------------------------------------------------------------------------------
