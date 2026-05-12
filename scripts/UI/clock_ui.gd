extends Control
class_name PoisonClockUI

@export var poison_manager: PoisonManager
@export var appear_delay: float = 1.0

@onready var clock_progress: TextureProgressBar = $ClockProgress
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var max_time := 1.0


func _ready() -> void:
	visible = false

	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.poison_updated.connect(_on_poison_updated)
	poison_manager.poison_ended.connect(_on_poison_ended)


func _on_poison_started(_snake: SnakeData) -> void:
	max_time = poison_manager.time_to_die

	await get_tree().create_timer(appear_delay).timeout

	visible = true
	# animation_player.play("appear")


func _on_poison_updated(time_left: float) -> void:
	var ratio: float = 1 - clamp(time_left / max_time, 0.0, 1.0)

	clock_progress.value = ratio


func _on_poison_ended(success: bool) -> void:
	if success:
		print("Clock: cured")
	else:
		print("Clock: dead")

	visible = false
