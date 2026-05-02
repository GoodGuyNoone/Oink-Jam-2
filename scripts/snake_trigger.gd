extends Area3D

@onready var poison_manager: Node = $"../Managers/PoisonManager"

var triggered := false


func _on_body_entered(body):
	if triggered:
		return

	if body.name == "Player":
		triggered = true
		poison_manager.apply_random_poison()
		print("Snake bit triggered")
