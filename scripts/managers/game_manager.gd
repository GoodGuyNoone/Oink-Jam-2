extends Node
class_name GameManager

@onready var poison_manager: PoisonManager = $"../PoisonManager"


func _ready() -> void:
	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.poison_updated.connect(_on_poison_updated)
	poison_manager.bottle_checked.connect(_on_bottle_checked)
	poison_manager.poison_ended.connect(_on_poison_ended)


func _on_poison_started(snake: SnakeData) -> void:
	print("\n=== POISON STARTED ===")
	print("Snake:", snake.name)
	print("Symptoms:", snake.symptoms)
	print("Required bottles:", snake.required_cure)
	print("================================")


func _on_poison_updated(time_left: float) -> void:
	print("Time left:", snapped(time_left, 0.1))


func _on_bottle_checked(
	bottle_id: String,
	is_correct: bool,
	picked_correct_count: int,
	required_count: int
) -> void:
	print("\nPicked:", bottle_id)

	if is_correct:
		print("→ Correct bottle (+time)")
	else:
		print("→ Wrong bottle (-time)")

	print("Progress:", picked_correct_count, "/", required_count)


func _on_poison_ended(success: bool) -> void:
	print("\n=== RESULT ===")

	if success:
		print("CURED ✅")
	else:
		print("DEAD 💀")

	print("=============\n")
