extends Control

# @export var readable_book: Node3D
@export var player: Node



func _ready():
	hide()


func open_ui():
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.can_look = false


func close_ui():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.can_look = true


func _on_next_button_pressed():
	player.book.next_spread()


func _on_previous_button_pressed():
	player.book.previous_spread()


func _on_close_button_pressed():
	player.book.close_book()
	close_ui()