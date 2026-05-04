extends Area3D
class_name BottleInteractable

@export var bottle_id: String
@export var display_name: String

@onready var poison_manager: Node = get_node("../../Managers/PoisonManager")
@onready var pick_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var picked := false


func get_interaction_text() -> String:
	return "Pick " + display_name


func interact(_interactor: Node) -> void:
	picked = true
	poison_manager.select_bottle(bottle_id)

	# TODO:
	# if pick_sound:
	# 	pick_sound.play()

	# if animation_player:
	# 	animation_player.play("pick")
	# 	await animation_player.animation_finished

	queue_free()
