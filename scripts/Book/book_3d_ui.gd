extends Node3D

@export var pages: Array[BookPageImage]

@onready var left_page: MeshInstance3D = $LeftPage
@onready var right_page: MeshInstance3D = $RightPage
@onready var flip_pivot: Node3D = $FlipPagePivot
@onready var flip_front: MeshInstance3D = $FlipPagePivot/FlipPageFront
@onready var flip_back: MeshInstance3D = $FlipPagePivot/FlipPageBack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_spread := 0
var is_flipping := false


func _ready():
	hide()
	show_spread(0)


func open_book():
	show()
	show_spread(current_spread)


func close_book():
	hide()


func get_total_spreads() -> int:
	return int(ceil(float(pages.size()) / 2.0))


func show_spread(spread_index: int):
	current_spread = spread_index

	var left_index := current_spread * 2
	var right_index := left_index + 1

	set_page_texture(left_page, pages[left_index].texture)

	if right_index < pages.size():
		set_page_texture(right_page, pages[right_index].texture)
	else:
		set_page_texture(right_page, null)


func set_page_texture(mesh: MeshInstance3D, texture: Texture2D):
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat


func next_spread():
	if is_flipping:
		return

	if current_spread >= get_total_spreads() - 1:
		return

	var next_left_index := (current_spread + 1) * 2

	set_page_texture(flip_front, right_page.material_override.albedo_texture)
	set_page_texture(flip_back, pages[next_left_index].texture)

	await flip_to_spread(current_spread + 1, "flip_forward")


func previous_spread():
	if is_flipping:
		return

	if current_spread <= 0:
		return

	var prev_right_index := (current_spread - 1) * 2 + 1

	set_page_texture(flip_front, left_page.material_override.albedo_texture)
	set_page_texture(flip_back, pages[prev_right_index].texture)

	await flip_to_spread(current_spread - 1, "flip_backward")


func flip_to_spread(new_spread: int, animation_name: String):
	is_flipping = true

	flip_pivot.show()

	animation_player.play(animation_name)

	await animation_player.animation_finished

	show_spread(new_spread)

	flip_pivot.hide()
	is_flipping = false
