extends Node
class_name GameManager

@export var player: Player
@export var poison_manager: PoisonManager
@export var inventory: Inventory
@export var symptom_effects_controller: SymptomEffectsController
@export var inspection_ui: InspectionUI
@export var end_sequence_controller: EndSequenceController

@onready var book_ui_button: BookUIButton = $"../../UI/BookUIButton"
@onready var inspection_sprite: TextureRect = $"../../UI/InspectionUI/InspectionSprite"


func _ready() -> void:
	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.item_checked.connect(_on_item_checked)
	poison_manager.poison_ended.connect(_on_poison_ended)
	inventory.item_used.connect(_on_inventory_item_used)


func _on_poison_started(snake: SnakeData) -> void:
	print("\n=== POISON STARTED ===")
	print("Snake:", snake.name)
	print("Symptoms:", str(snake.symptoms))
	print("Required items:", snake.required_cure)
	print("================================")


func _on_item_checked(item_id: String, is_correct: bool, picked_correct_count: int, required_count: int) -> void:
	print("\nPicked:", item_id)

	if is_correct:
		print("→ Correct item (+time)")
	else:
		print("→ Wrong item (-time)")

	print("Progress:", picked_correct_count, "/", required_count)


func _on_poison_ended(success: bool) -> void:
	if success:
		end_sequence_controller.play_success_sequence()
	else:
		end_sequence_controller.play_death_sequence()


func _on_inventory_item_used(item: ItemData) -> void:
	print("Inventory item triggered:", item.item_id)

	close_all_item_views()

	match item.item_id:
		"book":
			player.set_ui_mode(true)
			player.book.open_book()
			book_ui_button.open_ui()
		"thermometer":
			AudioManager.play_sfx("thermometer")
			player.set_ui_mode(true)
			inspection_ui.open(
				poison_manager.current_snake.temperature_sprite,
				false
			)
		"ruler":
			player.set_ui_mode(true)
			inspection_ui.open(
				poison_manager.current_snake.bite_sprite,
				true
			)

		_:
			print("No logic for:", item.item_id)


func close_all_item_views() -> void:
	if player.book:
		player.book.hide()

	if book_ui_button:
		book_ui_button.close_ui()

	if inspection_ui:
		inspection_ui.close()
