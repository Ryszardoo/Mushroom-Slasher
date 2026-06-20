extends Control

signal play_button_pressed
signal settings_button_pressed
signal about_button_pressed
signal exit_button_pressed


func _on_play_button_pressed() -> void:
	play_button_pressed.emit()


func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()


func _on_about_button_pressed() -> void:
	about_button_pressed.emit()


func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
