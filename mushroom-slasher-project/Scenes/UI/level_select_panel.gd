class_name LevelSelectPanel
extends Control

signal level_chosen(level_id: int)

@onready var level_1_button: TextureButton = %Level1Button
@onready var level_2_button: TextureButton = %Level2Button
@onready var level_3_button: TextureButton = %Level3Button
@onready var close_button: TextureButton = %CloseButton


func _ready() -> void:
	hide()

	level_1_button.pressed.connect(
		func() -> void:
			_choose_level(1)
	)

	level_2_button.pressed.connect(
		func() -> void:
			_choose_level(2)
	)

	level_3_button.pressed.connect(
		func() -> void:
			_choose_level(3)
	)

	close_button.pressed.connect(close)


func open() -> void:
	_refresh_buttons()
	show()


func close() -> void:
	hide()


func _refresh_buttons() -> void:
	level_1_button.disabled = (
		not ProgressionData.is_level_unlocked(1)
	)

	level_2_button.disabled = (
		not ProgressionData.is_level_unlocked(2)
	)

	level_3_button.disabled = (
		not ProgressionData.is_level_unlocked(3)
	)


func _choose_level(level_id: int) -> void:
	if not ProgressionData.is_level_unlocked(level_id):
		return

	hide()
	level_chosen.emit(level_id)
