extends Area3D
class_name BookInteractable

@export var book_ui_button: BookUIButton
@export var player: Player

var picked = false


func interact(_interactor: Node) -> void:
	picked = true

	# TODO:
	# if pick_sound:
	# 	pick_sound.play()

	# if animation_player:
	# 	animation_player.play("pick")
	# 	await animation_player.animation_finished

	open_book()
	queue_free()


func get_interaction_text() -> String:
	return "Pick guide book"


func open_book() -> void:
	player.book.open_book()
	book_ui_button.open_ui()


func _on_snake_trigger_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
