extends Node3D
class_name Snake

signal attached_to_player

@export var move_speed: float = 30.0
@export var attach_distance: float = 0.5
@export var escape_speed: float = 4.0

var is_escaping: bool = false
var escape_target_position: Vector3

@onready var head_point: Node3D = $HeadPoint
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target: Node3D
var is_attached: bool = false


func _physics_process(delta: float) -> void:
	if is_escaping:
		var run_target := escape_target_position
		run_target.y = global_position.y

		var direction := run_target - global_position

		if direction.length() < 0.1:
			is_escaping = false
			return

		global_position += direction.normalized() * escape_speed * delta
		_face_head_towards(run_target)
		return


	if is_attached or target == null:
		return

	_move_towards_target(delta)

	if _is_close_enough_to_attach():
		attach_to_player()


func attach_to_player() -> void:
	var attach_point := target.get_node("SnakeBitePoint") as Node3D

	reparent(attach_point)
	global_transform = attach_point.global_transform
	is_attached = true
	attached_to_player.emit()


func _face_head_towards(point: Vector3) -> void:
	var head_forward := -head_point.global_transform.basis.z
	var desired_forward := (point - head_point.global_position).normalized()

	if desired_forward.length() == 0.0:
		return

	var rotation_axis := head_forward.cross(desired_forward)

	if rotation_axis.length() == 0.0:
		return

	var angle := head_forward.angle_to(desired_forward)
	global_rotate(rotation_axis.normalized(), angle)


func detach_and_escape_to_point(point: Vector3) -> void:
	var old_global_transform := global_transform

	reparent(get_tree().current_scene, true)
	global_transform = old_global_transform

	target = null
	is_attached = false
	is_escaping = false

	var drop_target := global_position
	drop_target.y = point.y
	escape_target_position = point

	var tween := create_tween()
	tween.tween_property(self, "global_position", drop_target, 0.25)
	await tween.finished

	is_escaping = true


func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)
	await animation_player.animation_finished


func _move_towards_target(delta: float) -> void:
	var direction := (target.global_position - global_position).normalized()
	global_position += direction * move_speed * delta


func _is_close_enough_to_attach() -> bool:
	return global_position.distance_to(target.global_position) < attach_distance