class_name LevelUpAnnouncement
extends Control

@export var display_time: float = 1.5

@onready var level_label: Label = %LevelLabel

var _show_id: int = 0


func _ready() -> void:
	hide()


func show_level_up(new_level: int) -> void:
	_show_id += 1
	var current_id := _show_id

	level_label.text = "Level %d" % new_level
	show()

	await get_tree().create_timer(display_time).timeout

	if current_id == _show_id:
		hide()
