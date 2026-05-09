extends Resource
class_name SnakeData

@export var name: String
@export var snake_texture: StandardMaterial3D
@export var required_cure: Array[String] = []
@export var symptoms: Array[SymptomData] = []
@export var bite_sprite: Texture2D
@export var temperature_sprite: Texture2D