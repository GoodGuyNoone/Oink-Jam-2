extends Control
class_name MonologueUI

@export var text_label: Label
@export var continue_label: Label

var waiting_for_click := false
var finished := false


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP


func show_monologue(text: String) -> void:
	visible = true
	finished = false
	waiting_for_click = true

	text_label.text = text

	if continue_label:
		continue_label.visible = true


func wait_until_finished() -> void:
	while not finished:
		await get_tree().process_frame


func _gui_input(event: InputEvent) -> void:
	if not waiting_for_click:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_close()


func _close() -> void:
	waiting_for_click = false
	finished = true
	visible = false