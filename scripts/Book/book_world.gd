extends Area3D
class_name BookWorld

@export var book_ui_button: BookUIButton
@export var player: Player

var _player_near: bool = false


func _input(event: InputEvent) -> void:
	# if not _player_near:
	# 	return

	if event.is_action_pressed("Interact"):
		print("Interact pressed")
		open_book()


func open_book() -> void:
	player.book.open_book()
	book_ui_button.open_ui()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_player_near = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_player_near = false
