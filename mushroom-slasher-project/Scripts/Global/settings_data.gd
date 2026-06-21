extends Node

const SETTINGS_PATH := "user://settings.cfg"
const MASTER_BUS_NAME := "Master"

var master_volume: float = 1.0
var fullscreen: bool = false


func _ready() -> void:
	load_settings()
	apply_settings()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_audio()
	save_settings()


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	apply_display()
	save_settings()


func apply_settings() -> void:
	apply_audio()
	apply_display()


func apply_audio() -> void:
	var bus_index := AudioServer.get_bus_index(MASTER_BUS_NAME)

	if bus_index == -1:
		push_warning("Audio bus '%s' was not found." % MASTER_BUS_NAME)
		return

	if is_zero_approx(master_volume):
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(master_volume)
		)


func apply_display() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN \
		if fullscreen \
		else DisplayServer.WINDOW_MODE_WINDOWED

	DisplayServer.window_set_mode(mode)


func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"audio",
		"master_volume",
		master_volume
	)

	config.set_value(
		"display",
		"fullscreen",
		fullscreen
	)

	var error := config.save(SETTINGS_PATH)

	if error != OK:
		push_error(
			"Could not save settings. Error: %s" % error
		)


func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	# The file will not exist on the first launch.
	if error != OK:
		return

	master_volume = float(
		config.get_value(
			"audio",
			"master_volume",
			1.0
		)
	)

	fullscreen = bool(
		config.get_value(
			"display",
			"fullscreen",
			false
		)
	)
