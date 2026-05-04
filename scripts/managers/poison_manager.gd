extends Node
class_name PoisonManager

@export var snakes: Array[SnakeData]

signal poison_started(snake: SnakeData)
signal poison_updated(time_left: float)
signal poison_ended(success: bool)

var current_snake: SnakeData
var time_left: float = 0.0
var is_poisoned: bool = false


func _process(delta: float) -> void:
	if not is_poisoned:
		return

	_update_poison_timer(delta)


func apply_random_poison() -> void:
	if is_poisoned or snakes.is_empty():
		return

	current_snake = snakes.pick_random()
	time_left = current_snake.time_to_die
	is_poisoned = true
	poison_started.emit(current_snake)


func try_cure(action: String) -> void:
	if not is_poisoned:
		return

	_finish_poison(action == current_snake.cure)


func _update_poison_timer(delta: float) -> void:
	time_left -= delta
	poison_updated.emit(time_left)

	if time_left <= 0.0:
		_finish_poison(false)


func _finish_poison(success: bool) -> void:
	is_poisoned = false
	poison_ended.emit(success)
