extends Node

@export_category("Maps")
@export var base_camp_packed: PackedScene
@export var map_1_packed: PackedScene
@export var map_2_packed: PackedScene
@export var map_3_packed: PackedScene


@export_category("UI")
@export var end_game_screen_packed: PackedScene
@export var main_menu_packed: PackedScene

@onready var map_container: Node2D = $MapContainer
@onready var ui: CanvasLayer = $UI
@onready var level_hud: LevelHUD = $UI/LevelHUD
@onready var level_up_announcement: LevelUpAnnouncement = ($UI/LevelUpAnnouncement)

var current_scene: Node
var main_menu: Control
var current_level_id: int = 0
var end_game_screen: Control


func _ready() -> void:
	level_hud.hide_for_non_level()
	show_main_menu()
	

func show_main_menu() -> void:
	await _clear_current_map()
	_remove_end_game_screen()
	_remove_main_menu()

	if main_menu_packed == null:
		push_error("Main menu scene has not been assigned.")
		return

	main_menu = main_menu_packed.instantiate() as Control

	if main_menu == null:
		push_error("Main menu root must inherit Control.")
		return

	ui.add_child(main_menu)

	main_menu.play_button_pressed.connect(
		_on_main_menu_play_pressed
	)

	main_menu.settings_button_pressed.connect(
		_on_main_menu_settings_pressed
	)

	main_menu.about_button_pressed.connect(
		_on_main_menu_about_pressed
	)

	main_menu.exit_button_pressed.connect(
		_on_main_menu_exit_pressed
	)


func load_base_camp() -> void:
	level_hud.hide_for_non_level()
	
	current_level_id = 0
	await _replace_current_scene(base_camp_packed)
	_connect_base_camp()


func start_level(level_id: int) -> void:
	if not ProgressionData.is_level_unlocked(level_id):
		push_warning("Level %d is locked." % level_id)
		return

	var level_scene := _get_level_scene(level_id)

	if level_scene == null:
		push_error("No PackedScene configured for level %d." % level_id)
		return

	current_level_id = level_id

	await _replace_current_scene(level_scene)
	_connect_level_controller()


func respawn_current_level() -> void:
	if current_level_id <= 0:
		push_warning("There is no active level to respawn.")
		return

	start_level(current_level_id)


func _get_level_scene(level_id: int) -> PackedScene:
	match level_id:
		1:
			return map_1_packed
		2:
			return map_2_packed
		3:
			return map_3_packed
		_:
			return null


func _replace_current_scene(packed_scene: PackedScene) -> void:
	if packed_scene == null:
		push_error("Cannot load a null PackedScene.")
		return

	_remove_end_game_screen()

	if is_instance_valid(current_scene):
		current_scene.queue_free()
		await current_scene.tree_exited

	current_scene = packed_scene.instantiate()
	map_container.add_child(current_scene)


func _connect_level_controller() -> void:
	var controller := current_scene.find_child(
		"LevelExperienceController",
		true,
		false
	) as LevelExperienceController

	if controller == null:
		push_error(
			"The loaded level has no LevelExperienceController node."
		)
		return

	# Enemy clearance counter.
	if not controller.enemy_progress_changed.is_connected(
		level_hud.update_enemy_progress
	):
		controller.enemy_progress_changed.connect(
			level_hud.update_enemy_progress
		)

	level_hud.show_for_level(
		controller.killed_enemies,
		controller.total_enemies
	)

	# Player defeat.
	if not controller.level_finished.is_connected(
		_on_level_finished
	):
		controller.level_finished.connect(
			_on_level_finished
		)

	# XP bar.
	if not controller.experience_changed.is_connected(
		level_hud.update_experience
	):
		controller.experience_changed.connect(
			level_hud.update_experience
		)

	controller.emit_experience_changed()

	# Level-up announcement.
	if not controller.levelup.is_connected(
		level_up_announcement.show_level_up
	):
		controller.levelup.connect(
			level_up_announcement.show_level_up
		)

	# HP bar.
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("SceneHandler could not find the player.")
	else:
		if not player.health_changed.is_connected(
			level_hud.update_health
		):
			player.health_changed.connect(
				level_hud.update_health
			)

		level_hud.update_health(
			player.hitpoints,
			player.maximum_hitpoints
		)

	# Level progression.
	if current_scene.has_signal("next_level_requested"):
		if not current_scene.next_level_requested.is_connected(
			start_level
		):
			current_scene.next_level_requested.connect(
				start_level
			)

	if current_scene.has_signal("base_camp_requested"):
		if not current_scene.base_camp_requested.is_connected(
			load_base_camp
		):
			current_scene.base_camp_requested.connect(
				load_base_camp
			)

func _connect_base_camp() -> void:
	if not current_scene.has_signal("level_selected"):
		push_warning(
			"Base Camp has no level_selected(level_id) signal."
		)
		return

	if not current_scene.level_selected.is_connected(start_level):
		current_scene.level_selected.connect(start_level)

func _remove_main_menu() -> void:
	if is_instance_valid(main_menu):
		main_menu.queue_free()

	main_menu = null


func _clear_current_map() -> void:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		await current_scene.tree_exited

	current_scene = null

func _on_level_finished(victorious: bool) -> void:
	if victorious:
		ProgressionData.complete_level(current_level_id)

	_show_end_game_screen(victorious)


func _show_end_game_screen(victorious: bool) -> void:
	if is_instance_valid(end_game_screen):
		return

	if end_game_screen_packed == null:
		push_error("End-game screen scene is not assigned.")
		return

	end_game_screen = (
		end_game_screen_packed.instantiate() as Control
	)

	if end_game_screen == null:
		push_error("End-game screen root must inherit Control.")
		return

	end_game_screen.victorious = victorious

	end_game_screen.respawn_requested.connect(
		_on_respawn_requested
	)

	end_game_screen.base_camp_requested.connect(
		_on_base_camp_requested
	)

	ui.add_child(end_game_screen)


func _on_respawn_requested() -> void:
	_remove_end_game_screen()
	respawn_current_level()


func _on_base_camp_requested() -> void:
	_remove_end_game_screen()
	load_base_camp()


func _remove_end_game_screen() -> void:
	get_tree().paused = false

	if is_instance_valid(end_game_screen):
		end_game_screen.queue_free()

	end_game_screen = null

func _on_main_menu_play_pressed() -> void:
	_remove_main_menu()
	load_base_camp()


func _on_main_menu_settings_pressed() -> void:
	print("Open settings menu here.")


func _on_main_menu_about_pressed() -> void:
	print("Open about menu here.")


func _on_main_menu_exit_pressed() -> void:
	get_tree().quit()
