extends Node
class_name SnakeBiteController

@onready var snake_spawn: Node3D = get_node("../../SnakeTrigger")
@onready var snake_run_point: Node3D = get_node("../../SnakeRunPoint")
@onready var poison_manager: Node = $"../PoisonManager"
@onready var camera: Camera3D = get_node("../../Player/CameraMount/Camera3D")
@onready var snake_scene: PackedScene = preload("res://scenes/snake.tscn")
@onready var snake_instance: Node3D

@export var snake_escape_duration: float = 1.5
@export var bite_duration: float = 2.0
@export var camera_turn_duration: float = 0.5

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
	poison_manager.apply_random_poison()
	_spawn_snake()

	await _snake.attached_to_player
	await _play_bite_effects()
	await _look_at_bite_point()
	await _wait_for_bite_phase()
	await _detach_snake_and_watch()
	_remove_snake()
	await _restore_camera()


func _spawn_snake() -> void:
	_snake = snake_scene.instantiate() as Snake
	get_tree().current_scene.add_child(_snake)
	_snake.global_position = snake_spawn.global_position
	_snake.target = _player


func _look_at_bite_point() -> void:
	print("_look_at_bite_point()")
	var bite_point := _player.get_node("SnakeBitePoint") as Node3D
	_original_camera_transform = camera.global_transform
	_player.set_control_enabled(false)

	var target_transform := camera.global_transform.looking_at(bite_point.global_position, Vector3.UP)
	await _tween_camera_basis(camera.global_transform.basis, target_transform.basis)
	print("ended")


func _restore_camera() -> void:
	print("_restore_camera()")

	await _tween_camera_basis(camera.global_transform.basis, _original_camera_transform.basis)
	_player.set_control_enabled(true)
	print("ended()")



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
	print("_play_bite_effects()")
	# TODO: bite UI flash, screen shake, bite sound.
	await get_tree().create_timer(0.5).timeout
	print("ended")


func _wait_for_bite_phase() -> void:
	print("_wait_for_bite_phase()")
	_snake.play_animation("ArmatureAction")
	await get_tree().create_timer(bite_duration).timeout
	print("ended")


func _remove_snake() -> void:
	print("_remove_snake()")
	_snake.queue_free()
	print("ended()")


func _detach_snake_and_watch() -> void:
	print("_detach_snake_and_watch()")

	_snake.play_animation("ArmatureAction_001")
	await _snake.detach_and_escape_to_point(snake_run_point.global_position)

	var elapsed := 0.0

	while elapsed < snake_escape_duration and is_instance_valid(_snake):
		camera.look_at(_snake.global_position, Vector3.UP)

		await get_tree().process_frame
		elapsed += get_process_delta_time()

	print("ended")
