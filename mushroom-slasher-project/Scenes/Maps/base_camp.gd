extends Node2D

signal level_selected(level_id: int)

@onready var campfire: Campfire = $YSort/Campfire
@onready var level_select_panel: LevelSelectPanel = (
	$UI/LevelSelectPanel
)


func _ready() -> void:
	campfire.level_menu_requested.connect(
		level_select_panel.open
	)

	level_select_panel.level_chosen.connect(
		_on_level_chosen
	)


func _on_level_chosen(level_id: int) -> void:
	level_selected.emit(level_id)
