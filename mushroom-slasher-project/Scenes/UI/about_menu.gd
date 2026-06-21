class_name AboutMenu

extends Control
 
signal closed
 
@onready var back_button: BaseButton = %BackButton
 
 
func _ready() -> void:

	hide()
 
	if not back_button.pressed.is_connected(_on_back_pressed):

		back_button.pressed.connect(_on_back_pressed)
 
 
func open() -> void:

	show()

	back_button.grab_focus()
 
 
func close() -> void:

	hide()

	closed.emit()
 
 
func _on_back_pressed() -> void:

	close()
 
