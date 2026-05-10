extends StaticBody3D
class_name InteractableItem

enum InteractionType {
	CONSUME,
	PICKUP_TO_INVENTORY,
	PLAY_ANIMATION
}

@export var outline_material: Material
@export var interaction_type: InteractionType
@export var interaction_text: String = "Interact"
@export var item_data: ItemData
@export var inventory: Inventory
@export var animation_player: AnimationPlayer
@export var controller_node: InteractableItem
@export var consume_sound_id: String = ""
@export var pickup_sound_id: String = ""

@onready var poison_manager = get_node("/root/Main/Managers/PoisonManager")

var original_overlay_material: Material
var used := false
var opened := false


func _ready() -> void:
	add_to_group("interactable")


func get_interaction_text() -> String:
	if controller_node != null and controller_node != self:
		return controller_node.get_interaction_text()

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


func set_highlighted(enabled: bool) -> void:
	var mesh = find_child("MeshInstance3D", false, false)

	if mesh == null:
		return

	if enabled:
		mesh.material_overlay = outline_material
	else:
		mesh.material_overlay = null


func _consume_item() -> void:
	if not poison_manager.is_poisoned:
		return

	if item_data == null:
		return

	used = true

	if consume_sound_id != "":
		AudioManager.play_sfx(consume_sound_id, -2.0, 0.95, 1.08)

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

	if pickup_sound_id != "":
		AudioManager.play_sfx(pickup_sound_id, -4.0, 0.95, 1.05)

	used = true
	queue_free()


func _play_animation() -> void:
	if controller_node != null and controller_node != self:
		controller_node.interact(null)
		return

	if opened:
		animation_player.play("Close")
		interaction_text = "Open"
	else:
		animation_player.play("Open")
		interaction_text = "Close"

	opened = !opened
