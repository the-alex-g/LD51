extends CanvasLayer

onready var _hourglass = $Hourglass as AnimatedSprite
onready var _animation_player = $AnimationPlayer as AnimationPlayer


func _ready()->void:
	_hourglass.frame = 0


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
	get_tree().change_scene("res://Main/Main.tscn")
