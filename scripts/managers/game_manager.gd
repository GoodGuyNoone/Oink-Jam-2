extends Node
class_name GameManager

@export var player: Player
@export var poison_manager: PoisonManager
@export var inventory: Inventory

@onready var book_ui_button: BookUIButton = $"../../UI/BookUIButton"


func _ready() -> void:
	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.poison_updated.connect(_on_poison_updated)
	poison_manager.item_checked.connect(_on_item_checked)
	poison_manager.poison_ended.connect(_on_poison_ended)
	inventory.item_used.connect(_on_inventory_item_used)


func _on_poison_started(snake: SnakeData) -> void:
	print("\n=== POISON STARTED ===")
	print("Snake:", snake.name)
	print("Symptoms:", snake.symptoms)
	print("Required items:", snake.required_cure)
	print("================================")


func _on_poison_updated(time_left: float) -> void:
	return
	# print("Time left:", snapped(time_left, 0.1))


func _on_item_checked(item_id: String, is_correct: bool, picked_correct_count: int, required_count: int) -> void:
	print("\nPicked:", item_id)

	if is_correct:
		print("→ Correct item (+time)")
	else:
		print("→ Wrong item (-time)")

	print("Progress:", picked_correct_count, "/", required_count)


func _on_poison_ended(success: bool) -> void:
	print("\n=== RESULT ===")

	if success:
		print("CURED ✅")
	else:
		print("DEAD 💀")

	print("=============\n")


func _on_inventory_item_used(item: ItemData, slot_index: int) -> void:
	print("Inventory item triggered:", item.item_id)

	match item.item_id:
		"book":
				player.book.open_book()
				book_ui_button.open_ui()
		"key":
			print("Use key logic")
		_:
			print("No logic for:", item.item_id)
