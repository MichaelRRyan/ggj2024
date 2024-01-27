extends Control

signal restart_pressed


func _on_restart_button_pressed():
	emit_signal("restart_pressed")
