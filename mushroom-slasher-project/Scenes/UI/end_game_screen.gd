extends Control

signal respawn_requested
signal base_camp_requested

var victorious: bool = false


func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Update labels here according to `victorious`.
	# Example:
	# %Title.text = "Victory!" if victorious else "Defeated"


func _on_respawn_pressed() -> void:
	get_tree().paused = false
	respawn_requested.emit()


func _on_base_camp_pressed() -> void:
	get_tree().paused = false
	base_camp_requested.emit()
