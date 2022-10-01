extends CanvasLayer


func _ready()->void:
	$Hourglass.frame = 0


func _on_Main_game_over():
	$Hourglass.playing = false
