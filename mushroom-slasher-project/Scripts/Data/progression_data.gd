extends Node

var unlocked_levels: Array[int] = [1]
var completed_levels: Array[int] = []


func is_level_unlocked(level_id: int) -> bool:
	return level_id in unlocked_levels


func complete_level(level_id: int) -> void:
	if level_id not in completed_levels:
		completed_levels.append(level_id)

	var next_level := level_id + 1

	if next_level <= 3 and next_level not in unlocked_levels:
		unlocked_levels.append(next_level)
