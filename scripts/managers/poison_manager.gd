extends Node
class_name PoisonManager

@export var snakes: Array[SnakeData]
@export var time_to_die: float = 60.0
@export var correct_item_bonus_time: float = 3.0
@export var wrong_item_penalty_time: float = 5.0

signal poison_started(snake: SnakeData)
signal poison_updated(time_left: float)
signal poison_ended(success: bool)

signal item_checked(
	item_id: String,
	is_correct: bool,
	picked_correct: int,
	required_count: int
)

var current_snake: SnakeData
var time_left: float = 0.0
var elapsed_time: float = 0.0
var is_poisoned: bool = false

var picked_items: Array[String] = []
var picked_correct_items: Array[String] = []


func _process(delta: float) -> void:
	if not is_poisoned:
		return
	
	time_left -= delta
	elapsed_time += delta
	poison_updated.emit(time_left)

	if time_left <= 0:
		_finish_poison(false)


func apply_random_poison() -> void:
	if is_poisoned:
		return

	current_snake = snakes.pick_random()
	elapsed_time = 0.0
	time_left = time_to_die
	is_poisoned = true

	picked_correct_items.clear()
	poison_started.emit(current_snake)
	poison_updated.emit(time_left)


func select_item(item_id: String) -> void:
	if not is_poisoned:
		return
	
	picked_items.append(item_id)

	var is_correct := current_snake.required_cure.has(item_id)

	if is_correct:
		picked_correct_items.append(item_id)
		time_left += correct_item_bonus_time
	else:
		time_left -= wrong_item_penalty_time

	poison_updated.emit(time_left)

	item_checked.emit(
		item_id,
		is_correct,
		picked_correct_items.size(),
		current_snake.required_cure.size()
	)

	poison_updated.emit(time_left)

	if time_left <= 0.0:
		_finish_poison(false)
		return

	if _all_required_items_picked():
		_finish_poison(true)


func _all_required_items_picked() -> bool:
	for item_id in current_snake.required_cure:
		if not picked_correct_items.has(item_id):
			return false

	return true


func _finish_poison(success: bool) -> void:
	is_poisoned = false
	elapsed_time = 0.0
	picked_items.clear()
	picked_correct_items.clear()
	poison_ended.emit(success)
