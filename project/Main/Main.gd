extends Node2D

# main loop: https://www.beepbox.co/#9n31s0k0l00e03t2ma7g0fj07r1i0o432T1v4ue9f12meq0y10j53d4aA4F0BaQ0500Pf5a0E4ba61b62c75T1v6u30f0qwx10r511d08A9F4B0Q19e4Pb631E3b7626637T1v1u63f0qwx10n511d08A1F1B4Q50b0Pea3bE2b7628T3v3uf7f0qwx10m711d08SZIztrsrzrqiiiiiE1b6b4i400000000h8g000000014h000000004x400000000p21rHeO_7H_7BU117mRd7U-G5YC2nS0BZKBU4LjnY77Olc3bWy-ALFbWw02Czc4t17ohQCmCLabWui8W2f8Oyf9Oif9Oic0


signal ten_second_mark
signal player_update_speed(new_speed)
signal player_attack(heavy_attack)
signal game_over(victory)

const VICTORY_NUMBER := 15

var _rooms_passed := 0
var _enemies_defeated := 0

onready var _game_timer = $TenSecondTimer as Timer
onready var _sigh = $Sigh as AudioStreamPlayer


func _ready()->void:
	randomize()


func _on_TenSecondTimer_timeout()->void:
	emit_signal("ten_second_mark")
	_sigh.play()


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
	if _rooms_passed > 1:
		# warning-ignore:integer_division
		enemy.health += randi() % (_rooms_passed / 2)
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
