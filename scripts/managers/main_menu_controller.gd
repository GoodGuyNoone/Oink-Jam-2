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

@export var intro_duration: float = 3.0
@export var fade_duration: float = 0.6

@onready var player_camera: Camera3D = player.camera

var starting_game := false


func _ready() -> void:
	player.set_ui_mode(true)
	player.set_control_enabled(false)

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

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.set_control_enabled(true)


func _move_menu_camera_to_player_camera() -> void:
	var target_transform: Transform3D = player_camera.global_transform

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		menu_camera,
		"global_transform",
		target_transform,
		intro_duration
	)

	await tween.finished


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
	menu_panel.visible = false
	options_panel.visible = true


func _on_credits_button_pressed() -> void:
	menu_panel.visible = false
	credits_panel.visible = true


func _on_back_button_pressed() -> void:
	options_panel.visible = false
	credits_panel.visible = false
	menu_panel.visible = true


func _on_exit_button_pressed() -> void:
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
