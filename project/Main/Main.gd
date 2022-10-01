extends Node2D

signal ten_second_mark
signal game_over

onready var _game_timer = $TenSecondTimer as Timer


func _ready()->void:
	var enemy = preload("res://Enemies/Enemy.tscn").instance()
	enemy.target = $Player
	enemy.position = Vector2(100, 100)
	add_child(enemy)


func _on_TenSecondTimer_timeout()->void:
	emit_signal("ten_second_mark")


func _on_World_player_caught()->void:
	emit_signal("game_over")
	_game_timer.stop()
