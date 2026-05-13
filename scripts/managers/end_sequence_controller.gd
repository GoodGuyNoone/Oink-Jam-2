extends Node
class_name EndSequenceController

@export var player: Player
@export var black_fade: ColorRect

@export var spiral_duration: float = 4.0
@export var spiral_radius: float = 0.7
@export var spiral_height: float = 1.4
@export var spiral_back_distance: float = 2.0
@export var spiral_rotations: float = 0.65

@onready var camera = player.camera_mount

var sequence_running := false


func play_success_sequence() -> void:
	await _play_end_sequence(true)


func play_death_sequence() -> void:
	await _play_end_sequence(false)


func _play_end_sequence(success: bool) -> void:
	if sequence_running:
		return

	sequence_running = true

	if player:
		player.set_control_enabled(false)

	if success:
		player._play_animation("success")
	else:
		player._play_animation("death")

	_fade_to_black()
	await  _spiral_camera_away()

	if success:
		print("SUCCESS END SCREEN")
	else:
		print("DEATH END SCREEN")

	
func _spiral_camera_away() -> void:
	if camera == null:
		return

	var start_transform: Transform3D = camera.global_transform
	var start_pos: Vector3 = start_transform.origin
	var start_basis: Basis = start_transform.basis

	var forward: Vector3 = -start_basis.z.normalized()
	var right: Vector3 = start_basis.x.normalized()
	var up: Vector3 = Vector3.UP

	var elapsed := 0.0

	while elapsed < spiral_duration:
		var delta := get_process_delta_time()
		elapsed += delta

		var t = clamp(elapsed / spiral_duration, 0.0, 1.0)
		var eased := ease(t, 2.0)

		var angle := TAU * spiral_rotations * eased

		var spiral_offset: Vector3 = (
			right * cos(angle) * spiral_radius * eased
			+ up * sin(angle) * spiral_radius * 0.25 * eased
		)

		var away_offset: Vector3 = (
			-forward * spiral_back_distance * eased
			+ up * spiral_height * eased
		)

		camera.global_position = start_pos + spiral_offset + away_offset

		var yaw := sin(angle) * deg_to_rad(4.0) * eased
		var pitch := sin(angle * 0.7) * deg_to_rad(2.5) * eased
		var roll := sin(angle * 1.2) * deg_to_rad(3.0) * eased

		var rotation_offset := Basis(Vector3.UP, yaw)
		rotation_offset *= Basis(Vector3.RIGHT, pitch)
		rotation_offset *= Basis(Vector3.FORWARD, roll)

		camera.global_basis = start_basis * rotation_offset

		await get_tree().process_frame

func _fade_to_black() -> void:
	if black_fade == null:
		return

	black_fade.visible = true
	black_fade.color = Color(0, 0, 0, 0)

	var tween := create_tween()
	tween.tween_property(
		black_fade,
		"color",
		Color(0, 0, 0, 1),
		spiral_duration
	)
