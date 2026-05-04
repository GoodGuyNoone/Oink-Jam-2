extends Node3D
class_name Snake

signal attached_to_player

@export var move_speed: float = 30.0
@export var attach_distance: float = 0.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target: Node3D
var is_attached: bool = false


func _physics_process(delta: float) -> void:
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


func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)
	await animation_player.animation_finished


func _move_towards_target(delta: float) -> void:
	var direction := (target.global_position - global_position).normalized()
	global_position += direction * move_speed * delta


func _is_close_enough_to_attach() -> bool:
	return global_position.distance_to(target.global_position) < attach_distance
