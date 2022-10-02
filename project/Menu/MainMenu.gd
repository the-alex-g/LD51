extends Control

onready var _sfx_bus := AudioServer.get_bus_index("SFX")
onready var _music_bus := AudioServer.get_bus_index("Music")

func _ready()->void:
	_play_button_press()
	$VBoxContainer/MusicSlider.value = AudioServer.get_bus_volume_db(_music_bus)
	$VBoxContainer/SFXSlider.value = AudioServer.get_bus_volume_db(_sfx_bus)
	$VBoxContainer/CheckBox.pressed = OS.window_fullscreen


func _on_Button_pressed()->void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Main/Main.tscn")


func _on_MusicSlider_drag_ended(value_changed:bool)->void:
	_play_button_press()
	if value_changed:
		var new_value = $VBoxContainer/MusicSlider.value as float
		if new_value == -7.0:
			AudioServer.set_bus_mute(_music_bus, true)
		else:
			if AudioServer.is_bus_mute(_music_bus):
				AudioServer.set_bus_mute(_music_bus, false)
			AudioServer.set_bus_volume_db(_music_bus, new_value)


func _on_SFXSlider_drag_ended(value_changed:bool)->void:
	_play_button_press()
	if value_changed:
		var new_value = $VBoxContainer/SFXSlider.value as float
		if new_value == -7.0:
			AudioServer.set_bus_mute(_sfx_bus, true)
		else:
			if AudioServer.is_bus_mute(_sfx_bus):
				AudioServer.set_bus_mute(_sfx_bus, false)
			AudioServer.set_bus_volume_db(_sfx_bus, new_value)


func _on_CheckBox_toggled(button_pressed:bool)->void:
	_play_button_press()
	OS.window_fullscreen = button_pressed


func _play_button_press()->void:
	$ButtonPress.pitch_scale = lerp(0.96, 1.04, randf())
	$ButtonPress.volume_db += randf() / 8 - 0.0625
	$ButtonPress.play()
