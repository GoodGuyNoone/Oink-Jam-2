extends Node

@export var snakes: Array[SnakeData]

signal poison_started(snake: SnakeData)
signal poison_updated(time_left: float)
signal poison_ended(success: bool)

var current_snake: SnakeData
var time_left: float = 60.0
var is_poisoned := false


func apply_random_poison():
	if is_poisoned:
		return

	current_snake = snakes.pick_random()
	is_poisoned = true

	print("Bitten by:", current_snake.name)
	poison_started.emit(current_snake)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_poisoned:
		return
	
	time_left -= delta
	poison_updated.emit(time_left)

	if time_left <= 0:
		is_poisoned = false
		poison_ended.emit(false)


func try_cure(action: String):
	if not is_poisoned:
		return

	if action == current_snake.cure:
		print("Correct cure!")
		is_poisoned = false
		poison_ended.emit(true)
	else:
		print("Wrong cure")