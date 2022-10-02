extends Node2D

signal ten_second_mark
signal player_update_speed(new_speed)
signal player_attack(heavy_attack)
signal game_over(victory)

const VICTORY_NUMBER := 15

var _rooms_passed := 0
var _enemies_defeated := 0

onready var _game_timer = $TenSecondTimer as Timer


func _ready()->void:
	randomize()


func _on_TenSecondTimer_timeout()->void:
	emit_signal("ten_second_mark")


func _on_World_player_caught()->void:
	_end_game(false)


func _end_game(victory:bool)->void:
	emit_signal("game_over", victory)
	_game_timer.stop()
	# warning-ignore:integer_division
	$HUD.set_points(_rooms_passed + _enemies_defeated / 5)


func _on_World_add_enemy(at:Vector2)->void:
	var enemy := preload("res://Enemies/Enemy.tscn").instance()
	enemy.position = at
	if _rooms_passed > 0:
		enemy.health = max(enemy.health, randi() % _rooms_passed)
	enemy.target = $Player
	# warning-ignore:return_value_discarded
	connect("game_over", enemy, "_on_Main_game_over", [], CONNECT_ONESHOT)
	# warning-ignore:return_value_discarded
	enemy.connect("defeated", self, "_on_Enemy_defeated", [], CONNECT_ONESHOT)
	add_child(enemy)


func _on_World_passed_room()->void:
	_rooms_passed += 1
	if _rooms_passed >= VICTORY_NUMBER:
		_end_game(true)


func _on_Player_attack(heavy_attack:bool)->void:
	emit_signal("player_attack", heavy_attack)


func _on_Player_update_speed(new_speed:float)->void:
	emit_signal("player_update_speed", new_speed)


func _on_Enemy_defeated()->void:
	_enemies_defeated += 1
