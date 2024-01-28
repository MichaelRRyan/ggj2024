extends Node

var _num_minions = 0
var _ui : CanvasLayer = null
var _game_over_screen : Control = null

var DeathNotice = preload("res://features/ui_screens/death_notice/death_notice.tscn")


func _ready():
	# Get all minions, count number, connect death signal.
	var minions = get_tree().get_nodes_in_group("minion")
	_num_minions = minions.size()
	for node in minions:
		var minion = node as Minion
		minion.connect("died", _minion_died)
	
	# Find the UI node.
	var uis = get_tree().get_nodes_in_group("ui")
	if !uis.is_empty():
		_ui = uis.front()
		assert(_ui)
		_game_over_screen = _ui.get_node("GameOverScreen")
		assert(_game_over_screen)
		_game_over_screen.connect("restart_pressed", _restart_game)


func _minion_died(minion_name : String):
	var notice = DeathNotice.instantiate()
	$UI/Alerts.add_child(notice)
	notice.set_message(minion_name)
	
	_num_minions -= 1
	if _num_minions <= 0:
		print("Lost game")
		_game_over_screen.show()


func _restart_game():
	get_tree().reload_current_scene()
