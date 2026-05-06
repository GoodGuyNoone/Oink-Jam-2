extends Node
class_name SymptomEffectsController

@export var poison_manager: PoisonManager

@export var effect_trigger_times: Array[float] = [
	30.0,
	60.0,
	90.0,
	120.0
]

signal symptom_effect_triggered(symptom: SymptomData, symptom_index: int)

var queued_effect_symptoms: Array[SymptomData] = []
var triggered_indices: Array[int] = []


func _ready() -> void:
	poison_manager.poison_started.connect(_on_poison_started)
	poison_manager.poison_updated.connect(_on_poison_updated)
	poison_manager.poison_ended.connect(_on_poison_ended)


func _on_poison_started(snake: SnakeData) -> void:
	queued_effect_symptoms.clear()
	triggered_indices.clear()

	for symptom in snake.symptoms:
		if symptom.trigger_type == SymptomData.SymptomTriggerType.TIMED:
			queued_effect_symptoms.append(symptom)
	print("queued_effect_symptoms: ", str(queued_effect_symptoms))


func _on_poison_updated(time_left: float) -> void:
	var elapsed := poison_manager.time_to_die - time_left

	for i in range(effect_trigger_times.size()):
		if triggered_indices.has(i):
			continue

		if i >= queued_effect_symptoms.size():
			continue

		var trigger_time := effect_trigger_times[i]

		if elapsed >= trigger_time:
			triggered_indices.append(i)
			_trigger_symptom(i)


func _trigger_symptom(symptom_index: int) -> void:
	var symptom := queued_effect_symptoms[symptom_index]

	print("Triggered symptom:", symptom.display_name)

	symptom_effect_triggered.emit(symptom, symptom_index)


func _on_poison_ended(_success: bool) -> void:
	queued_effect_symptoms.clear()
	triggered_indices.clear()