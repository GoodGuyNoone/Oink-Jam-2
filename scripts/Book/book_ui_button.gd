extends Control
class_name BookUIButton

@export var player: Player


func _ready() -> void:
	hide()


func open_ui() -> void:
	show()
	player.can_look = false


func close_ui() -> void:
	hide()
	player.can_look = true
	player.set_ui_mode(false)


func _on_next_button_pressed() -> void:
	player.book.next_spread()


func _on_previous_button_pressed() -> void:
	player.book.previous_spread()


func _on_close_button_pressed() -> void:
	player.book.close_book()
	close_ui()
