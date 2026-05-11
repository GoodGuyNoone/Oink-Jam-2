extends Control
class_name Inventory

const MAX_SLOTS := 3

@export var key_icons: Array[CompressedTexture2D]

signal item_used(item: ItemData)

var items: Array[ItemData] = [null, null, null]
var slot_icons: Array[InventorySlot] = []


func _ready() -> void:
	_collect_slots()
	_setup_key_icons()
	_refresh_ui()
	

func _collect_slots() -> void:
	slot_icons.clear()

	for child in $HBoxContainer.get_children():
		if child is InventorySlot:
			slot_icons.append(child)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("use_slot_1"):
		use_slot(0)

	if Input.is_action_just_pressed("use_slot_2"):
		use_slot(1)

	if Input.is_action_just_pressed("use_slot_3"):
		use_slot(2)


func try_add_item(item: ItemData) -> bool:
	for i in range(MAX_SLOTS):
		if items[i] == null:
			items[i] = item
			print("Added to inventory:", item.display_name, "slot:", i + 1)
			_refresh_ui()
			return true

	print("Inventory full")
	return false


func use_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return

	var item := items[slot_index]

	if item == null:
		print("Slot", slot_index + 1, "is empty")
		return

	print("Used inventory item:", item.display_name)

	item_used.emit(item)


func _refresh_ui() -> void:
	for i in range(slot_icons.size()):
		slot_icons[i].set_item(items[i])


func _setup_key_icons() -> void:
	for i in range(slot_icons.size()):
		if i < key_icons.size():
			slot_icons[i].set_key_icon(key_icons[i])
