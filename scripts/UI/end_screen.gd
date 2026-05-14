extends Control
class_name EndScreen

@export var result_label: Label
@export var play_again_button: Button
@export var exit_button: Button


func _ready() -> void:
	visible = false
	play_again_button.pressed.connect(_on_play_again_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func show_success() -> void:
	_show_end_screen("You got lucky today.

Turns out carrying random medical supplies into the forest was actually a good idea.

But seriously — in real life, snake bites are no JOKE.
Stay calm, CALL emergency services, and never rely on guessing.")


func show_death() -> void:
	_show_end_screen("Well... that could've gone better.

At least now you know that “random pills and optimism”
isn't a medically approved treatment plan.

Seriously though — snake bites are DANGEROUS.
In real life, seek professional medical help IMMEDIATELY.")


func _show_end_screen(text: String) -> void:
	visible = true
	result_label.text = text

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_pressed() -> void:
	get_tree().quit()
