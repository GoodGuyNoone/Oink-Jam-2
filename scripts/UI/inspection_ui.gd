extends Control
class_name InspectionUI

@export var player: Player
@export var inspection_sprite: TextureRect
@export var close_button: Button
# @export var ruler_cursor: Texture2D
@export var ruler_cursor_icon: TextureRect


var is_open := false
var is_ruler_mode := false


func _process(_delta: float) -> void:
	if ruler_cursor_icon.visible:
		ruler_cursor_icon.global_position = get_global_mouse_position() - ruler_cursor_icon.size * 0.5


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
	if is_ruler_mode:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		ruler_cursor_icon.visible = true


func _on_sprite_mouse_exited() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ruler_cursor_icon.visible = false