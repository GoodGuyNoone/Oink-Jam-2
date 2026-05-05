extends Panel
class_name InventorySlot

@onready var item_icon: TextureRect = $IconBorder/ItemIcon
@onready var key_icon: TextureRect = $KeyIcon


func set_item(item: ItemData) -> void:
	if item == null:
		item_icon.texture = null
		item_icon.visible = false
	else:
		item_icon.texture = item.icon
		item_icon.visible = true


func set_key_icon(texture: Texture2D) -> void:
	key_icon.texture = texture