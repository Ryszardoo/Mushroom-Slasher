class_name LevelExperienceController
extends Node

signal levelup(new_level: int)
signal experience_changed(current_experience: int, required_experience: int, current_level: int)
signal level_finished(victorious: bool)
signal game_over(victorious: bool)
signal enemy_progress_changed(killed: int, total: int)
signal map_cleared

var total_enemies: int = 0
var killed_enemies: int = 0
var player: Node

var level_has_finished := false
var map_is_cleared := false


func _ready() -> void:
	add_to_group("level_controller")

	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("LevelExperienceController did not find the player.")
		return

	_connect_existing_enemies()

	enemy_progress_changed.emit(
		killed_enemies,
		total_enemies
	)

	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)

	if player.has_signal("game_over"):
		if not player.game_over.is_connected(_on_player_game_over):
			player.game_over.connect(_on_player_game_over)
	else:
		push_warning("Player has no game_over signal.")

	if player.has_method("calculate_stats"):
		if not levelup.is_connected(_on_levelup):
			levelup.connect(_on_levelup)
	else:
		push_warning("Player has no calculate_stats() method.")

	emit_experience_changed()


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)


func _connect_existing_enemies() -> void:
	var enemy_array: Array[Node] = (
		get_tree().get_nodes_in_group("enemies")
	)

	total_enemies = enemy_array.size()

	for enemy: Node in enemy_array:
		_connect_enemy(enemy)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("enemies"):
		total_enemies += 1
		_connect_enemy.call_deferred(node)
		
		enemy_progress_changed.emit(killed_enemies, total_enemies)


func _connect_enemy(enemy: Node) -> void:
	if not enemy.has_signal("died"):
		push_warning(
			"Node '%s' is in the enemies group but has no died signal."
			% enemy.name
		)
		return

	if not enemy.died.is_connected(_on_enemy_died):
		enemy.died.connect(_on_enemy_died)


func _on_enemy_died(exp_reward: int) -> void:
	if level_has_finished:
		return

	killed_enemies += 1
	experience_gained(exp_reward)

	enemy_progress_changed.emit(
		killed_enemies,
		total_enemies
	)

	if (
		not map_is_cleared
		and total_enemies > 0
		and killed_enemies >= total_enemies
	):
		map_is_cleared = true
		map_cleared.emit()


func _on_player_game_over(_victorious: bool) -> void:
	_finish_level(false)


func _finish_level(victorious: bool) -> void:
	if level_has_finished:
		return

	level_has_finished = true
	level_finished.emit(victorious)
	
func is_map_cleared() -> bool:
	return map_is_cleared

func get_remaining_enemies() -> int:
	return maxi(total_enemies - killed_enemies, 0)

func emit_experience_changed() -> void:
	if PlayerData.level >= LevelData.MAX_LEVEL:
		experience_changed.emit(
			1,
			1,
			PlayerData.level
		)
		return

	var required_experience: int = (
		LevelData.LEVEL_THRESHOLDS[
			PlayerData.level - 1
		]
	)

	experience_changed.emit(
		PlayerData.experience,
		required_experience,
		PlayerData.level
	)
	
func experience_gained(exp_gain: int) -> void:
	if PlayerData.level >= LevelData.MAX_LEVEL:
		return

	PlayerData.experience += exp_gain

	while (
		PlayerData.level < LevelData.MAX_LEVEL
		and PlayerData.experience
		>= LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]
	):
		level_up()
	
	emit_experience_changed()


func level_up() -> void:
	var required_experience: int = (
		LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]
	)

	PlayerData.experience -= required_experience
	PlayerData.level += 1

	print("Player reached level ", PlayerData.level)
	levelup.emit(PlayerData.level)

func _on_levelup(_new_level: int) -> void:
	player.calculate_stats()
