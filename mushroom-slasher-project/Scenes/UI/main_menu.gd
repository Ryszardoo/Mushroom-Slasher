extends Control


signal play_button_pressed(origin: String)
signal settings_button_pressed(origin: String)
signal about_button_pressed(origin: String)
signal exit_button_pressed(origin: String)

func _on_play_button_pressed() -> void:
	play_button_pressed.emit("main_menu")


func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit("main_menu")


func _on_about_button_pressed() -> void:
	about_button_pressed.emit("main_menu")


func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit("main_menu")
