class_name LevelHUD
extends Control

@onready var hp_bar: TextureProgressBar = %HPBar
@onready var hp_label: Label = %HPLabel
@onready var xp_bar: TextureProgressBar = %XPBar
@onready var xp_label: Label = %XPLabel
@onready var enemy_counter: Label = %EnemyCounter


func show_for_level(killed: int, total: int) -> void:
	show()
	update_enemy_progress(killed, total)


func hide_for_non_level() -> void:
	hide()


func update_enemy_progress(killed: int, total: int) -> void:
	enemy_counter.text = "Enemies: %d / %d" % [
		killed,
		total
	]


func update_health(
	current_health: int,
	maximum_health: int
) -> void:
	hp_bar.max_value = maximum_health
	hp_bar.value = current_health

	hp_label.text = "%d / %d" % [
		current_health,
		maximum_health
	]

func update_experience(
	current_experience: int,
	required_experience: int,
	current_level: int
) -> void:
	xp_bar.max_value = required_experience
	xp_bar.value = current_experience

	if current_level >= LevelData.MAX_LEVEL:
		xp_label.text = "Level %d — MAX" % current_level
	else:
		xp_label.text = "Lv.%d  %d / %d XP" % [
			current_level,
			current_experience,
			required_experience
		]
