extends Area3D
class_name InteractableItem

enum InteractionType {
	CONSUME,
	PICKUP_TO_INVENTORY,
	PLAY_ANIMATION
}

@export var interaction_type: InteractionType
@export var interaction_text: String = "Interact"
@export var item_data: ItemData
@export var inventory: Inventory
@export var animation_player: AnimationPlayer

@onready var poison_manager: PoisonManager = $"../../Managers/PoisonManager"

var used := false


func _ready() -> void:
	add_to_group("interactable")


func get_interaction_text() -> String:
	if item_data:
		return interaction_text + " " + item_data.display_name

	return interaction_text


func interact(_interactor: Node) -> void:
	if used:
		return

	match interaction_type:
		InteractionType.CONSUME:
			_consume_item()

		InteractionType.PICKUP_TO_INVENTORY:
			_pickup_to_inventory()

		InteractionType.PLAY_ANIMATION:
			_play_animation()


func _consume_item() -> void:
	if not poison_manager.is_poisoned:
		return

	if item_data == null:
		return

	used = true

	if poison_manager:
		poison_manager.select_item(item_data.item_id)

	queue_free()


func _pickup_to_inventory() -> void:
	if item_data == null:
		return

	if inventory == null:
		return

	var added := inventory.try_add_item(item_data)

	if not added:
		print("Inventory full")
		return

	# used = true
	# queue_free()


func _play_animation() -> void:
	used = true

	if animation_player:
		animation_player.play("open")
