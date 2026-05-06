extends Resource
class_name SymptomData

enum SymptomTriggerType {
	TIMED,
	INSPECTION
}

enum InspectionTool {
	NONE,
	RULER,
	THERMOMETER
}

@export var symptom_id: String
@export var display_name: String

@export var trigger_type: SymptomTriggerType
@export var inspection_tool: InspectionTool

# Optional timed effects
@export var visual_effect_id: String = ""
@export var sound_effect_id: String = ""

# Optional inspection clue
@export var clue_text: String = ""
@export var clue_texture: Texture2D