extends Control
class_name SymptomEffectsUI

@export var symptom_controller: SymptomEffectsController
@export var poison_manager: PoisonManager

@export var overlay: ColorRect
@export var tremor_audio: AudioStreamPlayer
@export var breath_audio: AudioStreamPlayer
@export var heartbeat_audio: AudioStreamPlayer
@export var tremor_timer: Timer

var shader_material: ShaderMaterial
var effect_time := 0.0

var active_dizziness := false
var active_tremor := false
var active_breathing := false
var active_heartbeat := false


func _ready() -> void:
	shader_material = overlay.material as ShaderMaterial

	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = true

	symptom_controller.symptom_effect_triggered.connect(_on_symptom_effect_triggered)
	poison_manager.poison_ended.connect(_on_poison_ended)
	tremor_timer.timeout.connect(_on_tremor_timer_timeout)

	_reset_all_effects()


func _process(delta: float) -> void:
	effect_time += delta

	if shader_material:
		shader_material.set_shader_parameter("time", effect_time)


func _on_symptom_effect_triggered(symptom: SymptomData, _index: int) -> void:
	print("Triggered symptom: " + str(symptom))
	if symptom.visual_effect_id != "":
		_apply_visual_effect(symptom.visual_effect_id)

	if symptom.sound_effect_id != "":
		_apply_sound_effect(symptom.sound_effect_id)


func _apply_visual_effect(effect_id: String) -> void:
	print("applying: " + effect_id)
	match effect_id:
		"dizziness":
			start_dizziness()

		"tremor":
			start_tremor()

		"heartbeat":
			start_heartbeat_visual()

		_:
			push_warning("Unknown visual effect: " + effect_id)


func _apply_sound_effect(effect_id: String) -> void:
	print("applying: " + effect_id)
	match effect_id:
		"difficultyBreathing":
			start_breathing_audio()

		"heartbeat":
			start_heartbeat_audio()

		"tremor":
			start_tremor_audio()

		_:
			push_warning("Unknown sound effect: " + effect_id)


func start_dizziness() -> void:
	active_dizziness = true
	_tween_shader_value("dizziness_intensity", 1.0, 1.5)


func start_tremor() -> void:
	active_tremor = true
	tremor_timer.wait_time = 5.0
	tremor_timer.start()
	_play_tremor_burst()


func start_heartbeat_visual() -> void:
	active_heartbeat = true
	_tween_shader_value("heartbeat_intensity", 1.0, 1.0)


func start_breathing_audio() -> void:
	active_breathing = true
	AudioManager.play_sfx("heavyBreathing", -5.0, 1.0, 1.0, "Symptoms")


func start_heartbeat_audio() -> void:
	active_heartbeat = true
	AudioManager.play_sfx("heartbeat", -4.0, 1.0, 1.0, "Symptoms")


func start_tremor_audio() -> void:
	active_tremor = true

	if not tremor_timer.is_stopped():
		return

	tremor_timer.wait_time = 5.0
	tremor_timer.start()
	_play_tremor_burst()


func _on_tremor_timer_timeout() -> void:
	if active_tremor:
		_play_tremor_burst()


func _play_tremor_burst() -> void:
	if tremor_audio:
		tremor_audio.play()

	_tween_shader_value("tremor_intensity", 1.0, 0.08)

	await get_tree().create_timer(0.45).timeout

	if active_tremor:
		_tween_shader_value("tremor_intensity", 0.0, 0.25)


func _on_poison_ended(_success: bool) -> void:
	_reset_all_effects()


func _reset_all_effects() -> void:
	active_dizziness = false
	active_tremor = false
	active_breathing = false
	active_heartbeat = false

	if tremor_timer:
		tremor_timer.stop()

	AudioManager.stop_bus("Symptoms")

	if shader_material:
		shader_material.set_shader_parameter("dizziness_intensity", 0.0)
		shader_material.set_shader_parameter("tremor_intensity", 0.0)
		shader_material.set_shader_parameter("heartbeat_intensity", 0.0)


func _tween_shader_value(parameter_name: String, target_value: float, duration: float) -> void:
	if shader_material == null:
		return

	var current_value: float = shader_material.get_shader_parameter(parameter_name)

	var tween := create_tween()
	tween.tween_method(
		func(value: float) -> void:
			shader_material.set_shader_parameter(parameter_name, value),
		current_value,
		target_value,
		duration
	)
