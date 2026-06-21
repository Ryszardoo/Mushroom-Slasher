class_name SettingsMenu
extends Control

signal closed

@onready var master_volume_slider: HSlider = (
	%MasterVolumeSlider
)

@onready var fullscreen_check_box: CheckBox = (
	%FullscreenCheckBox
)

@onready var back_button: BaseButton = %BackButton


func _ready() -> void:
	hide()

	master_volume_slider.value_changed.connect(
		_on_master_volume_changed
	)

	fullscreen_check_box.toggled.connect(
		_on_fullscreen_toggled
	)

	back_button.pressed.connect(
		_on_back_pressed
	)


func open() -> void:
	master_volume_slider.set_value_no_signal(
		SettingsData.master_volume * 100.0
	)

	fullscreen_check_box.set_pressed_no_signal(
		SettingsData.fullscreen
	)

	show()
	back_button.grab_focus()


func close() -> void:
	hide()
	closed.emit()


func _on_master_volume_changed(value: float) -> void:
	SettingsData.set_master_volume(
		value / 100.0
	)


func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsData.set_fullscreen(enabled)


func _on_back_pressed() -> void:
	close()
