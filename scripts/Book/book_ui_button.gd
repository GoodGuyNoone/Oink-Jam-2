extends Control
class_name BookUIButton

@export var player: Player


func _ready() -> void:
	hide()


func open_ui() -> void:
	player.ui_mode = true
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.can_look = false


func close_ui() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.can_look = true
	player.ui_mode = false


func _on_next_button_pressed() -> void:
	player.book.next_spread()


func _on_previous_button_pressed() -> void:
	player.book.previous_spread()


func _on_close_button_pressed() -> void:
	player.book.close_book()
	close_ui()
