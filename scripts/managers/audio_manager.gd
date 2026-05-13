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
	],
	"relief": [
		preload("res://assets/sound/relief-01.ogg"),
		preload("res://assets/sound/relief-02.ogg"),
		preload("res://assets/sound/relief-03.ogg"),
	],
	"hurt": [
		preload("res://assets/sound/hurt-01.ogg"),
		preload("res://assets/sound/hurt-02.ogg"),
		preload("res://assets/sound/hurt-03.ogg"),
	],
	"openBook": [
		preload("res://assets/sound/bookOpen.ogg"),
	],
	"closeBook": [
		preload("res://assets/sound/bookClose.ogg"),
	],
	"thermometer": [
		preload("res://assets/sound/thermometer-01.ogg"),
		preload("res://assets/sound/thermometer-02.ogg"),
	],
	"mouseEntered": [
		preload("res://assets/sound/Modern10.ogg"),
	],
	"startClicked": [
		preload("res://assets/sound/Modern9.ogg"),
	],
	"otherClicked": [
		preload("res://assets/sound/Modern7.ogg"),
	],
	"success": [
		preload("res://assets/sound/success.ogg"),
	],
	"death": [
		preload("res://assets/sound/death.ogg"),
	],
	"snakeBite": [
		preload("res://assets/sound/snakeBite.ogg"),
	],
	"snakeRunAway": [
		preload("res://assets/sound/snakeRunAway.ogg"),
	],
}

var music := {
	"ambient": preload("res://assets/sound/ambient.ogg"),
}

var music_player: AudioStreamPlayer


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	music_player.bus = "Music"
	music_player.volume_db = -14.0


func play_music(music_id: String, volume_db := -14.0) -> void:
	if not music.has(music_id):
		push_warning("AudioManager: missing music id: " + music_id)
		return

	if music_player.playing and music_player.stream == music[music_id]:
		return

	music_player.stream = music[music_id]
	music_player.volume_db = volume_db
	music_player.play()


func play_sfx(sound_id: String, volume_db := 0.0, pitch_min := 0.96, pitch_max := 1.04, bus := "SFX") -> AudioStreamPlayer:
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

	return player


