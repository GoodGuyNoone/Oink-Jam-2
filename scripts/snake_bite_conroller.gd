extends Area3D

@onready var poison_manager: Node = $"../Managers/PoisonManager"
@onready var snake_spawn: Node3D = $"../SnakeSpawn"
@onready var camera: Camera3D = $"../Player/CameraMount/Camera3D"


var original_camera_position: Transform3D
var triggered := false
# var player = null


func _on_body_entered(body):
	if triggered:
		return

	if body.name == "Player":
		triggered = true
		poison_manager.apply_random_poison()
		spawn_snake(body)
		play_effects()
		move_camera_on_snake(body)


func spawn_snake(player):
	var snake = preload("res://scenes/snake.tscn").instantiate()
	get_tree().current_scene.add_child(snake)

	snake.global_transform.origin = snake_spawn.global_transform.origin
	snake.target = player


func move_camera_on_snake(player):
	print("Camera started moving")
	var attach_point = player.get_node("SnakeBitePoint")
	var start_basis = camera.global_transform.basis
	original_camera_position = camera.global_transform

	player.set_physics_process(false)
	player.set_process(false)
	player.can_look = false

	var target_transform = camera.global_transform.looking_at(
		attach_point.global_transform.origin,
		Vector3.UP
	)

	var end_basis = target_transform.basis

	var tween = create_tween()
	tween.tween_method(
		func(weight):
			camera.global_transform.basis = start_basis.slerp(end_basis, weight),
		0.0, 1.0, 0.5)

	await tween.finished

	# wait for snake animation a run away

	player.set_physics_process(true)
	player.set_process(true)

	restore_camera()

	player.can_look = true


func restore_camera():
	var start_basis = camera.global_transform.basis
	var end_basis = original_camera_position.basis

	var tween = create_tween()
	tween.tween_method(
		func(weight):
			camera.global_transform.basis = start_basis.slerp(end_basis, weight),
		0.0, 1.0, 0.5)

	await tween.finished


func play_effects():
	# ui effects for bite
	# bite sound

	return get_tree().create_timer(0.5).timeout

# # 3. Wait while snake is attached
# func wait_phase():
# 	return get_tree().create_timer(2.0).timeout

# # 4. Wiggle + detach
# func detach_snake():
# 	await snake.play_wiggle_animation()

# 	snake.detach()
# 	snake.run_away() # your logic

# 	return get_tree().create_timer(0.5).timeout

# # 5. Restore player + camera
# func restore_player():
# 	player.set_physics_process(true)

# 	camera.move_to(original_camera_target)
# 	ui.hide_snake_bite_warning()
