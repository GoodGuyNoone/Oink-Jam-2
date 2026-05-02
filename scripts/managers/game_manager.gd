extends Node

@onready var poison_manager: Node = $"../PoisonManager"


func _ready() -> void:
	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.poison_updated.connect(_on_poison_updated)
	poison_manager.poison_ended.connect(_on_poison_ended)


func _on_poison_started(snake):
	print("Player poisoned: " + snake.name)
	print("Symptoms" + str(snake.symptoms))
	# trigger UI, hints, sound, etc 


func _on_poison_updated(time_left):
	return


func _on_poison_ended(success):
	if success:
		print("Player survived")
	else:
		print("Game over")
