extends Node3D
class_name BookUI

@export var pages: Array[BookPageImage]

@onready var left_page: MeshInstance3D = $LeftPage
@onready var right_page: MeshInstance3D = $RightPage
@onready var flip_pivot: Node3D = $FlipPagePivot
@onready var flip_front: MeshInstance3D = $FlipPagePivot/FlipPageFront
@onready var flip_back: MeshInstance3D = $FlipPagePivot/FlipPageBack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_spread: int = 0
var is_flipping: bool = false


func _ready() -> void:
	hide()
	flip_pivot.hide()
	_show_spread(0)


func open_book() -> void:
	show()
	_show_spread(current_spread)


func close_book() -> void:
	hide()


func next_spread() -> void:
	if is_flipping or current_spread >= _get_total_spreads() - 1:
		return

	var next_left_page := (current_spread + 1) * 2
	_set_page_texture(flip_front, _get_page_texture(current_spread * 2 + 1))
	_set_page_texture(flip_back, _get_page_texture(next_left_page))
	await _flip_to_spread(current_spread + 1, "flip_forward")


func previous_spread() -> void:
	if is_flipping or current_spread <= 0:
		return

	var previous_right_page := (current_spread - 1) * 2 + 1
	_set_page_texture(flip_front, _get_page_texture(current_spread * 2))
	_set_page_texture(flip_back, _get_page_texture(previous_right_page))
	await _flip_to_spread(current_spread - 1, "flip_backward")


func _show_spread(spread_index: int) -> void:
	if pages.is_empty():
		_set_page_texture(left_page, null)
		_set_page_texture(right_page, null)
		return

	current_spread = clampi(spread_index, 0, _get_total_spreads() - 1)
	var left_index := current_spread * 2
	var right_index := left_index + 1

	_set_page_texture(left_page, _get_page_texture(left_index))
	_set_page_texture(right_page, _get_page_texture(right_index))


func _get_total_spreads() -> int:
	return int(ceil(float(pages.size()) / 2.0))


func _get_page_texture(page_index: int) -> Texture2D:
	if page_index < 0 or page_index >= pages.size():
		return null
	return pages[page_index].texture


func _set_page_texture(mesh: MeshInstance3D, texture: Texture2D) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = material


func _flip_to_spread(new_spread: int, animation_name: String) -> void:
	is_flipping = true
	flip_pivot.show()
	animation_player.play(animation_name)
	await animation_player.animation_finished
	_show_spread(new_spread)
	flip_pivot.hide()
	is_flipping = false
