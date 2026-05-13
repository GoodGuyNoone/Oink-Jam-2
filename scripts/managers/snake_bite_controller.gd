extends Node
class_name SnakeBiteController

@onready var snake_spawn: Node3D = get_node("../../SnakeTrigger")
@onready var snake_run_point: Node3D = get_node("../../SnakeRunPoint")
@onready var poison_manager: Node = $"../PoisonManager"
@onready var camera: Camera3D = get_node("../../Environment/Player/CameraMount/Camera3D")
@onready var snake_scene: PackedScene = preload("res://scenes/snake.tscn")
@onready var snake_instance: Node3D

@export var snake_escape_duration: float = 1.5
@export var bite_duration: float = 2.0
@export var camera_turn_duration: float = 0.5
@export var bite_sound: AudioStreamPlayer
@export var bite_flash: ColorRect
@export var monologue_ui: MonologueUI

var _player: Player
var _snake: Snake
var _original_camera_transform: Transform3D
var _has_triggered: bool = false


func _on_body_entered(body: Node3D) -> void:
	if _has_triggered or not body is Player:
		return

	_has_triggered = true
	_player = body
	await _run_bite_sequence()


func _run_bite_sequence() -> void:
	poison_manager.pick_random_snake()
	_spawn_snake()

	await _snake.attached_to_player
	await _play_bite_effects()
	await _look_at_bite_point()
	await _wait_for_bite_phase()
	await _detach_snake_and_watch()
	_remove_snake()
	_player.set_ui_mode(true)
	monologue_ui.show_monologue(
		"Damn it... I remember I have a medkit in the car, but I don't have much time."
	)
	await monologue_ui.wait_until_finished()
	await _restore_camera()

	_player.set_ui_mode(false)
	_player.set_control_enabled(true)

	poison_manager.apply_random_poison()


func _spawn_snake() -> void:
	_snake = snake_scene.instantiate() as Snake
	get_tree().current_scene.add_child(_snake)
	
	_snake.global_position = snake_spawn.global_position
	_snake.target = _player

	var snake_mesh := _snake.get_node("Armature/Skeleton3D/Cube") as MeshInstance3D
	snake_mesh.material_override = poison_manager.current_snake.snake_texture


func _look_at_bite_point() -> void:
	print("_look_at_bite_point()")
	var bite_point := _player.get_node("SnakeBitePoint") as Node3D
	_original_camera_transform = camera.global_transform
	_player.set_control_enabled(false)
	_player._play_animation("idle")

	var target_transform := camera.global_transform.looking_at(bite_point.global_position, Vector3.UP)
	await _tween_camera_basis(camera.global_transform.basis, target_transform.basis)
	print("ended")


func _restore_camera() -> void:
	await _tween_camera_basis(camera.global_transform.basis, _original_camera_transform.basis)
	_player.set_control_enabled(true)




func _tween_camera_basis(from_basis: Basis, to_basis: Basis) -> void:
	var tween := create_tween()
	tween.tween_method(
		func(weight: float) -> void:
			camera.global_transform.basis = from_basis.slerp(to_basis, weight),
		0.0,
		1.0,
		camera_turn_duration
	)
	await tween.finished


func _play_bite_effects() -> void:
	AudioManager.play_sfx("snakeBite", -10)
	if bite_sound:
		bite_sound.play()

	if bite_flash:
		bite_flash.visible = true
		bite_flash.color = Color(1.0, 0.0, 0.0, 0.0)

		var tween := create_tween()
		tween.tween_property(bite_flash, "color", Color(1.0, 0.0, 0.0, 0.45), 0.08)
		tween.tween_property(bite_flash, "color", Color(1.0, 0.0, 0.0, 0.0), 0.35)

	await get_tree().create_timer(0.5).timeout



func _wait_for_bite_phase() -> void:
	_snake.play_animation("ArmatureAction")
	await get_tree().create_timer(bite_duration).timeout


func _remove_snake() -> void:
	_snake.queue_free()


func _detach_snake_and_watch() -> void:
	AudioManager.play_sfx("snakeRunAway", -10)
	_snake.play_animation("ArmatureAction_001")
	await _snake.detach_and_escape_to_point(snake_run_point.global_position)

	var elapsed := 0.0

	while elapsed < snake_escape_duration and is_instance_valid(_snake):
		camera.look_at(_snake.global_position, Vector3.UP)

		await get_tree().process_frame
		elapsed += get_process_delta_time()
