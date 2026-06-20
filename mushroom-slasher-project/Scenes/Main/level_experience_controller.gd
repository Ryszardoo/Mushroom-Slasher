class_name LevelExperienceController
extends Node

signal levelup
signal level_finished(victorious: bool)
signal game_over(victorious: bool)

var total_enemies: int = 0
var killed_enemies: int = 0
var player: Node

var level_has_finished := false


func _ready() -> void:
	add_to_group("level_controller")

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("LevelExperienceController did not find the player.")
		return

	if player.has_signal("game_over"):
		player.game_over.connect(_on_player_game_over)
	else:
		push_warning("Player has no game_over signal.")
	
	
	_connect_existing_enemies()
	get_tree().node_added.connect(_on_node_added)

	if player.has_signal("game_over"):
		player.game_over.connect(_on_player_game_over)
	else:
		push_warning("Player has no 'game_over' signal.")

	if player.has_method("calculate_stats"):
		levelup.connect(player.calculate_stats)
	else:
		push_warning("Player has no calculate_stats() method.")


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

	if total_enemies > 0 and killed_enemies >= total_enemies:
		_finish_level(true)


func _on_player_game_over(_victorious: bool) -> void:
	_finish_level(false)


func _finish_level(victorious: bool) -> void:
	if level_has_finished:
		return

	level_has_finished = true
	level_finished.emit(victorious)


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


func level_up() -> void:
	var required_experience: int = (
		LevelData.LEVEL_THRESHOLDS[PlayerData.level - 1]
	)

	PlayerData.experience -= required_experience
	PlayerData.level += 1

	print("Player reached level ", PlayerData.level)
	levelup.emit()
