extends CanvasLayer

onready var _hourglass = $Hourglass as AnimatedSprite
onready var _animation_player = $AnimationPlayer as AnimationPlayer
onready var _primary_attacks = $PrimaryAttacks as VBoxContainer
onready var _heavy_attacks = $HeavyAttacks as VBoxContainer


func _ready()->void:
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


func _on_Main_ten_second_mark()->void:
	_add_attack_icons()
