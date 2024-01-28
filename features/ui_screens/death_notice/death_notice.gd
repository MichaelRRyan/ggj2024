extends Label


func set_message(minion_name : String):
	text = minion_name + " has died."


func _ready():
	$AnimationPlayer.play("appear_and_fade")


func _on_animation_player_animation_finished(anim_name):
	queue_free()
