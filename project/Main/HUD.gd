extends CanvasLayer

onready var _hourglass = $Hourglass as AnimatedSprite
onready var _animation_player = $AnimationPlayer as AnimationPlayer
onready var _primary_attacks = $PrimaryAttacks as VBoxContainer
onready var _heavy_attacks = $HeavyAttacks as VBoxContainer
onready var _speed_bar = $SpeedBar as ProgressBar
onready var _point_label = $TextureRect/Panel/VBoxContainer/ScoreLabel as Label


func _ready()->void:
	# the button press play is a carry-over from the main menu play button being pressed
	$ButtonPress.play()
	_hourglass.frame = 0
	_add_attack_icons()


func _add_attack_icons()->void:
	for i in 3:
		var icon := TextureRect.new()
		icon.texture = preload("res://Resources/PrimaryAttackIcon.tres")
		_primary_attacks.add_child(icon)
	var icon := TextureRect.new()
	icon.texture = preload("res://Resources/HeavyAttackIcon.tres")
	_heavy_attacks.add_child(icon)


func _on_Main_game_over(victory:bool):
	_hourglass.playing = false
	if victory:
		_animation_player.play("Victory")
	else:
		_animation_player.play("Defeat")


func _on_PlayAgain_pressed()->void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Main/Main.tscn")


func _on_MainMenu_pressed()->void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Menu/MainMenu.tscn")


func _on_Main_player_attack(heavy_attack:bool)->void:
	if heavy_attack:
		_heavy_attacks.get_child(0).queue_free()
	else:
		_primary_attacks.get_child(0).queue_free()


func set_points(value:int)->void:
	_point_label.text = "Score: " + str(value)


func _on_Main_ten_second_mark()->void:
	_add_attack_icons()


func _on_Main_player_update_speed(new_speed:float)->void:
	_speed_bar.value = new_speed
