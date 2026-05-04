extends Node3D

@export var book_3dbutton_ui: Control
@export var player: Node


var player_near := false


func _input(event):
	if event.is_action_pressed("Interact"):
		player.book.open_book()
		book_3dbutton_ui.open_ui()
