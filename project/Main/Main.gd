extends Node2D

signal ten_second_mark
signal game_over

onready var _game_timer = $TenSecondTimer as Timer


func _ready()->void:
	randomize()


func _on_TenSecondTimer_timeout()->void:
	emit_signal("ten_second_mark")


func _on_World_player_caught()->void:
	emit_signal("game_over")
	_game_timer.stop()


func _on_World_add_enemy(at:Vector2)->void:
	var enemy := preload("res://Enemies/Enemy.tscn").instance()
	enemy.position = at
	enemy.target = $Player
	# warning-ignore:return_value_discarded
	connect("game_over", enemy, "_on_Main_game_over")
	add_child(enemy)
