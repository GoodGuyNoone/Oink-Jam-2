extends Node
class_name PoisonManager

@export var snakes: Array[SnakeData]
@export var time_to_die: float = 60.0
@export var correct_bottle_bonus_time: float = 3.0
@export var wrong_bottle_penalty_time: float = 5.0

signal poison_started(snake: SnakeData)
signal poison_updated(time_left: float)
signal poison_ended(success: bool)

signal bottle_checked(
	bottle_id: String,
	is_correct: bool,
	picked_correct: int,
	required_count: int
)

var current_snake: SnakeData
var time_left: float = 0.0
var is_poisoned: bool = false

var picked_bottles: Array[String] = []
var picked_correct_bottles: Array[String] = []


func _process(delta: float) -> void:
	if not is_poisoned:
		return
	
	time_left -= delta
	poison_updated.emit(time_left)

	if time_left <= 0:
		_finish_poison(false)


func apply_random_poison() -> void:
	if is_poisoned:
		return

	current_snake = snakes.pick_random()
	time_left = time_to_die
	is_poisoned = true

	picked_correct_bottles.clear()
	poison_started.emit(current_snake)
	poison_updated.emit(time_left)


func select_bottle(bottle_id: String) -> void:
	picked_bottles.append(bottle_id)

	var is_correct := current_snake.required_cure.has(bottle_id)

	if is_correct:
		picked_correct_bottles.append(bottle_id)
		time_left += correct_bottle_bonus_time
	else:
		time_left -= wrong_bottle_penalty_time

	bottle_checked.emit(
		bottle_id,
		is_correct,
		picked_correct_bottles.size(),
		current_snake.required_cure.size()
	)

	poison_updated.emit(time_left)

	if time_left <= 0.0:
		_finish_poison(false)
		return

	if _all_required_bottles_picked():
		_finish_poison(true)


func _all_required_bottles_picked() -> bool:
	for bottle_id in current_snake.required_cure:
		if not picked_correct_bottles.has(bottle_id):
			return false

	return true


func _finish_poison(success: bool) -> void:
	is_poisoned = false
	picked_bottles.clear()
	picked_correct_bottles.clear()
	poison_ended.emit(success)
