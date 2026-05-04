extends Node
class_name GameManager

@onready var poison_manager: PoisonManager = $"../PoisonManager"

func _ready() -> void:
	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.poison_updated.connect(_on_poison_updated)
	poison_manager.poison_ended.connect(_on_poison_ended)


func _on_poison_started(snake: SnakeData) -> void:
	print("Player poisoned by: %s" % snake.display_name)
	print("Symptoms: %s" % str(snake.symptoms))
	# TODO: show poison UI, start heartbeat, show hints, play sound.


func _on_poison_updated(time_left: float) -> void:
	# TODO: update poison timer UI.
	pass


func _on_poison_ended(success: bool) -> void:
	if success:
		print("Player survived")
		# TODO: hide poison UI and play cure feedback.
	else:
		print("Game over")
		# TODO: load fail screen or restart level.
