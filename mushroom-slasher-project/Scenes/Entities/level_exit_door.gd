class_name LevelExitDoor
extends Area2D

signal exit_requested

var level_controller: LevelExperienceController

@onready var locked_message: Label = $LockedMessage


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	locked_message.hide()


func setup(
	controller: LevelExperienceController
) -> void:
	level_controller = controller


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if level_controller == null:
		push_error(
			"LevelExitDoor has no LevelExperienceController."
		)
		return

	if level_controller.is_map_cleared():
		monitoring = false
		exit_requested.emit()
	else:
		_show_locked_message()


func _show_locked_message() -> void:
	var remaining := (
		level_controller.get_remaining_enemies()
	)

	locked_message.text = (
		"Enemies remaining: %d" % remaining
	)

	locked_message.show()

	await get_tree().create_timer(1.5).timeout

	if is_instance_valid(locked_message):
		locked_message.hide()
