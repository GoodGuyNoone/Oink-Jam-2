extends Area3D

@onready var poison_manager: Node = $"../Managers/PoisonManager"
@onready var snake_spawn: Node3D = $"../SnakeSpawn"

var triggered := false


func _on_body_entered(body):
	if triggered:
		return

	if body.name == "Player":
		triggered = true
		poison_manager.apply_random_poison()
		spawn_snake(body)
		print("Snake bit triggered")


func spawn_snake(player):
	var snake = preload("res://scenes/snake.tscn").instantiate()
	get_tree().current_scene.add_child(snake)

	snake.global_transform.origin = snake_spawn.global_transform.origin
	snake.target = player
