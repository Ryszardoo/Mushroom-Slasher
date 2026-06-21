class_name LevelMap
extends Node2D

signal next_level_requested(level_id: int)
signal base_camp_requested

@export_range(1, 3)
var level_id: int = 1

@export_range(0, 3)
var next_level_id: int = 0

@export var return_to_base_camp: bool = false

@onready var level_controller: LevelExperienceController = (
	%LevelExperienceController
)

@onready var level_exit_door: LevelExitDoor = (
	%LevelExitDoor
)


func _ready() -> void:
	level_exit_door.setup(level_controller)

	level_exit_door.exit_requested.connect(
		_on_exit_requested
	)


func _on_exit_requested() -> void:
	if not level_controller.is_map_cleared():
		return

	ProgressionData.complete_level(level_id)

	if return_to_base_camp or next_level_id == 0:
		base_camp_requested.emit()
	else:
		next_level_requested.emit(next_level_id)
