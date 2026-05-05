extends Control
class_name Inventory

const MAX_SLOTS := 3

@export var slot_icons: Array[TextureRect]

signal item_used(item: ItemData, slot_index: int)

var items: Array[ItemData] = [null, null, null]


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

	item_used.emit(item, slot_index)
	_refresh_ui()


func _refresh_ui() -> void:
	for i in range(slot_icons.size()):
		var icon := slot_icons[i]

		if items[i] == null:
			icon.texture = null
			icon.visible = false
		else:
			icon.texture = items[i].icon
			icon.visible = true
