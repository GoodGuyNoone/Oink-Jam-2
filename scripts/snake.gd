extends Node3D

signal attached_to_player

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var target = null
var speed = 30
var attached = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if attached or target == null:
		return

	var dir = (target.global_transform.origin - global_transform.origin).normalized()
	translate(dir * speed * delta)
	# look_at(target.global_transform.origin, Vector3.UP)
	print("moving to a player")
	if global_transform.origin.distance_to(target.global_transform.origin) < 0.5:
		attach_to_player()


func attach_to_player():
	print("Snake attached to a player")
	var attach_point = target.get_node("SnakeBitePoint")

	get_parent().remove_child(self)
	attach_point.add_child(self)
	global_transform = attach_point.global_transform
	attached = true
	attached_to_player.emit()


func play_animation(animation: String) -> void:
	print("Playing animation" + str(animation))
	animation_player.play(animation)
	await animation_player.animation_finished
