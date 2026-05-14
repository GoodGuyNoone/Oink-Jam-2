extends Node
class_name MainMenuController

@export var player: Player
@export var menu_camera: Camera3D

@export var main_menu: Control
@export var menu_panel: Control
@export var options_panel: Control
@export var credits_panel: Control
@export var fade_black: ColorRect
@export var terrain: Terrain3D
@export var inventory: Inventory
@export var monologue_ui: MonologueUI
@export var warning_screen: WarningScreen

@export var intro_duration: float = 3.0
@export var fade_duration: float = 0.6

@onready var player_camera: Camera3D = player.camera

var starting_game := false


func _ready() -> void:
	main_menu.visible = false
	warning_screen.visible = true
	warning_screen.continued.connect(_on_warning_continued)

	AudioManager.play_music("ambient")
	player.set_ui_mode(true)
	player.set_control_enabled(false)
	inventory.hide()


	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	main_menu.visible = true
	menu_panel.visible = true
	options_panel.visible = false
	credits_panel.visible = false

	menu_panel.modulate.a = 1.0

	if fade_black:
		fade_black.visible = true
		fade_black.color = Color(0, 0, 0, 1)

	menu_camera.current = true
	player_camera.current = false

	_fade_from_black()


func _on_start_button_pressed() -> void:
	if starting_game:
		return

	AudioManager.play_sfx("startClicked")
	starting_game = true
	await _start_game()
	player.set_ui_mode(false)
	player.set_control_enabled(true)


func _start_game() -> void:
	_disable_menu_buttons()

	_fade_menu_out()

	await _move_menu_camera_to_player_camera()

	menu_camera.current = false
	player_camera.current = true
	terrain.set_camera(player_camera)

	main_menu.visible = false

	player.set_ui_mode(true)

	monologue_ui.show_monologue("What a nice hike. Let's head home.")
	await monologue_ui.wait_until_finished()

	player.set_ui_mode(false)
	inventory.show()
	player.set_control_enabled(true)


func _move_menu_camera_to_player_camera() -> void:
	var start_transform: Transform3D = menu_camera.global_transform
	var end_transform: Transform3D = player_camera.global_transform

	var start_pos: Vector3 = start_transform.origin
	var end_pos: Vector3 = end_transform.origin

	var mid_pos: Vector3 = (start_pos + end_pos) * 0.5
	mid_pos.y += 4.0 # lift camera over terrain

	var elapsed := 0.0

	while elapsed < intro_duration:
		var delta := get_process_delta_time()
		elapsed += delta

		var t = clamp(elapsed / intro_duration, 0.0, 1.0)
		var eased := ease(t, -2.0)

		var a := start_pos.lerp(mid_pos, eased)
		var b := mid_pos.lerp(end_pos, eased)
		var curved_pos := a.lerp(b, eased)

		menu_camera.global_position = curved_pos
		menu_camera.global_basis = start_transform.basis.slerp(
			end_transform.basis,
			eased
		)

		await get_tree().process_frame

	menu_camera.global_transform = end_transform


func _fade_menu_out() -> void:
	var tween := create_tween()

	tween.tween_property(
		menu_panel,
		"modulate:a",
		0.0,
		fade_duration
	)


func _disable_menu_buttons() -> void:
	menu_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	options_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credits_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_options_button_pressed() -> void:
	_on_other_pressed()
	menu_panel.visible = false
	options_panel.visible = true


func _on_credits_button_pressed() -> void:
	_on_other_pressed()
	menu_panel.visible = false
	credits_panel.visible = true


func _on_back_button_pressed() -> void:
	options_panel.visible = false
	credits_panel.visible = false
	menu_panel.visible = true


func _on_exit_button_pressed() -> void:
	_on_other_pressed()
	get_tree().quit()


func _fade_from_black() -> void:
	if fade_black == null:
		return

	var tween := create_tween()

	tween.tween_property(
		fade_black,
		"color",
		Color(0, 0, 0, 0),
		2.0
	)


func _on_mouse_entered() -> void:
	AudioManager.play_sfx("mouseEntered", -4)


func _on_other_pressed() -> void:
	AudioManager.play_sfx("otherClicked")


func _on_warning_continued() -> void:
	main_menu.visible = true
	menu_panel.visible = true
	options_panel.visible = false
	credits_panel.visible = false

	_fade_from_black()
