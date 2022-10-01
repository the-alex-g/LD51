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
