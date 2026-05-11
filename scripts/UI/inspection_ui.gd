extends Control
class_name InspectionUI

@export var player: Player
@export var inspection_sprite: TextureRect
@export var close_button: Button
@export var ruler_cursor: Texture2D


var is_open := false
var is_ruler_mode := false


func _ready() -> void:
	visible = false
	close_button.pressed.connect(close)

	inspection_sprite.mouse_entered.connect(_on_sprite_mouse_entered)
	inspection_sprite.mouse_exited.connect(_on_sprite_mouse_exited)


func open(texture: Texture2D, use_ruler: bool = false) -> void:
	is_open = true
	is_ruler_mode = use_ruler

	inspection_sprite.texture = texture
	visible = true

	if player:
		player.velocity.x = 0
		player.velocity.z = 0
		player.can_look = false
		player.can_move = false


func close() -> void:
	is_open = false
	is_ruler_mode = false

	visible = false

	if player:
		player.can_look = true
		player.can_move = true
		player.set_ui_mode(false)


func _on_sprite_mouse_entered() -> void:
	if is_ruler_mode and ruler_cursor:
		Input.set_custom_mouse_cursor(ruler_cursor)


func _on_sprite_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(player.cursor_open)
