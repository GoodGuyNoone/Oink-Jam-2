extends Node

var sounds := {
	"openTablets": [
		preload("res://assets/sound/openTablets.ogg"),
	],
	"useSyrup": [
		preload("res://assets/sound/useSyrup.ogg"),
	],
	"useSyringe": [
		preload("res://assets/sound/useSyringe.ogg")
	],
	"flipPage": [
		preload("res://assets/sound/flipPage1.ogg"),
		preload("res://assets/sound/flipPage2.ogg"),
		preload("res://assets/sound/flipPage3.ogg"),
		preload("res://assets/sound/flipPage4.ogg"),
	]
}


func play_sfx(sound_id: String, volume_db := 0.0, pitch_min := 0.96, pitch_max := 1.04, bus := "SFX") -> void:
	if not sounds.has(sound_id):
		push_warning("AudioManager: missing sound id: " + sound_id)
		return

	var stream: AudioStream = sounds[sound_id].pick_random()

	var player := AudioStreamPlayer.new()
	add_child(player)

	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_min, pitch_max)

	player.finished.connect(player.queue_free)
	player.play()
