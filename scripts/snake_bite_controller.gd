extends Area3D
class_name SnakeBiteController

@export var poison_manager: PoisonManager
@export var snake_spawn: Node3D
@export var camera: Camera3D
@export var snake_scene: PackedScene
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
	await _remove_snake()
	await _restore_camera()


func _spawn_snake() -> void:
	_snake = snake_scene.instantiate() as Snake
	get_tree().current_scene.add_child(_snake)
	_snake.global_position = snake_spawn.global_position
	_snake.target = _player


func _look_at_bite_point() -> void:
	var bite_point := _player.get_node("SnakeBitePoint") as Node3D
	_original_camera_transform = camera.global_transform
	_player.set_control_enabled(false)

	var target_transform := camera.global_transform.looking_at(bite_point.global_position, Vector3.UP)
	await _tween_camera_basis(camera.global_transform.basis, target_transform.basis)


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
	# TODO: bite UI flash, screen shake, bite sound.
	await get_tree().create_timer(0.5).timeout


func _wait_for_bite_phase() -> void:
	await get_tree().create_timer(bite_duration).timeout


func _remove_snake() -> void:
	await _snake.play_animation("SnakeArmature|Snake_Idle")
	_snake.queue_free()
