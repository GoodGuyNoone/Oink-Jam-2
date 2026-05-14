extends Control
class_name WarningScreen

signal continued

@export var continue_button: Button


func _ready() -> void:
	visible = true
	continue_button.pressed.connect(_on_continue_pressed)


func _on_continue_pressed() -> void:
	visible = false
	continued.emit()