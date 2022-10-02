extends Control


func _input(event:InputEvent)->void:
	if event is InputEventKey:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Menu/MainMenu.tscn")
