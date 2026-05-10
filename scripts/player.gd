extends CharacterBody3D
class_name Player

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 5.0
@export var movement_lerp_speed: float = 10
@export var mouse_sensitivity: float = 0.25
@export var walk_animation_speed_threshold: float = 0.2

@onready var book: BookUI = $CameraMount/Camera3D/BookUI
@onready var ray_cast_3d: RayCast3D = get_node("CameraMount/Camera3D/RayCast3D")
@onready var camera_mount: Node3D = $CameraMount
@onready var interaction_label: Label = get_node("../UI/InteractionLabel")
@onready var animation_player: AnimationPlayer = $player/AnimationPlayer


var can_look: bool = true
var can_move: bool = true
var _current_speed: float = walk_speed
var _move_direction: Vector3 = Vector3.ZERO
var current_target: Node

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_play_animation("idle")


func _input(event: InputEvent) -> void:
	_handle_mouse_look(event)


func _physics_process(delta: float) -> void:
	_update_target()

	if Input.is_action_just_pressed("Interact") and current_target:
		current_target.interact(owner)

	_update_speed()
	_apply_gravity(delta)
	# _handle_jump()
	_handle_movement(delta)
	move_and_slide()
	_update_movement_animation()


func set_control_enabled(enabled: bool) -> void:
	can_look = enabled
	set_physics_process(enabled)
	set_process(enabled)


func _handle_mouse_look(event: InputEvent) -> void:
	if not can_look:
		return

	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _update_speed() -> void:
	_current_speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


# func _handle_jump() -> void:
# 	if Input.is_action_just_pressed("jump") and is_on_floor():
# 		velocity.y = jump_velocity


func _handle_movement(delta: float) -> void:
	if not can_move:
		return
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var target_direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_move_direction = lerp(_move_direction, target_direction, movement_lerp_speed * delta)

	if _move_direction:
		velocity.x = _move_direction.x * _current_speed
		velocity.z = _move_direction.z * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed)
		velocity.z = move_toward(velocity.z, 0, _current_speed)


func _update_target() -> void:
	if current_target:
		current_target.set_highlighted(false)

	if interaction_label:
		interaction_label.visible = false

	if not ray_cast_3d:
		return

	if not ray_cast_3d.is_colliding():
		return

	var hit := ray_cast_3d.get_collider()

	if hit == null:
		return

	if not hit.is_in_group("interactable"):
		return

	if not hit.has_method("interact"):
		return

	current_target = hit

	if current_target.has_method("set_highlighted"):
		current_target.set_highlighted(true)

	if interaction_label:
		interaction_label.visible = true

		if hit.has_method("get_interaction_text"):
			interaction_label.text = hit.get_interaction_text()
		else:
			interaction_label.text = "Interact"


func _try_interact() -> void:
	if not ray_cast_3d.is_colliding():
		return

	var hit := ray_cast_3d.get_collider()

	if hit and hit.has_method("interact"):
		hit.interact()


func _update_movement_animation() -> void:
	if animation_player == null:
		return

	var horizontal_velocity := velocity
	horizontal_velocity.y = 0.0

	var speed := horizontal_velocity.length()

	if speed < walk_animation_speed_threshold:
		_play_animation("idle")
	elif Input.is_action_pressed("sprint"):
		_play_animation("running")
	else:
		_play_animation("walking")


func _play_animation(animation_name: String) -> void:
	if animation_name == "":
		return

	if animation_player.current_animation == animation_name:
		return

	if not animation_player.has_animation(animation_name):
		push_warning("Animation not found: " + animation_name)
		return

	animation_player.play(animation_name)
