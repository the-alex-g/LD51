extends Node2D

signal ten_second_mark


func _ready()->void:
	var enemy = preload("res://Enemies/Enemy.tscn").instance()
	enemy.target = $Player
	enemy.position = Vector2(100, 100)
	add_child(enemy)
	$Hourglass.frame = 0


func _on_TenSecondTimer_timeout()->void:
	emit_signal("ten_second_mark")
