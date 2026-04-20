extends Node

## 音效管理器 — 三段式音樂設計 + Cut to Silence 效果

const BGM_BUS_NAME := "BGM"
const SFX_BUS_NAME := "SFX"
const DIALOGIC_AUDIO_CHANNEL_DEFAULTS := {
	"": {
		"volume": 0.0,
		"audio_bus": SFX_BUS_NAME,
		"fade_length": 0.0,
		"loop": false,
	},
	"music": {
		"volume": 0.0,
		"audio_bus": BGM_BUS_NAME,
		"fade_length": 0.0,
		"loop": true,
	},
}

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer

## 用戶音量設定（線性值 0.0~1.0）
var bgm_volume: float = 0.45
var sfx_volume: float = 0.2

var _bgm_tween: Tween


func _ready() -> void:
	_configure_dialogic_audio_routing()

	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.bus = BGM_BUS_NAME
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = SFX_BUS_NAME
	add_child(sfx_player)

	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "AmbiencePlayer"
	ambience_player.bus = BGM_BUS_NAME
	add_child(ambience_player)

	set_bgm_volume(bgm_volume)
	set_sfx_volume(sfx_volume)


## 設定 BGM bus 音量（同時影響 Dialogic 的 [music] 和環境音）
func set_bgm_volume(value: float) -> void:
	bgm_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(BGM_BUS_NAME)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(bgm_volume))


## 設定 SFX bus 音量（同時影響 Dialogic 的 [sound] 音效）
func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index(SFX_BUS_NAME)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))


## 序章：史詩交響樂 + 大火音效
func play_prologue_epic() -> void:
	var bgm_stream = _safe_load("res://audio/bgm/prologue_epic.ogg")
	if bgm_stream:
		_crossfade_bgm(bgm_stream, 1.0, -12.0)
	var fire_stream = _safe_load("res://audio/sfx/fire_burning.ogg")
	if fire_stream:
		ambience_player.stream = fire_stream
		ambience_player.play()


## 核心效果：Cut to Silence（瞬間靜音）
## 用於忠臣刺殺瞬間 — 所有聲音瞬間消失
func cut_to_silence() -> void:
	if _bgm_tween:
		_bgm_tween.kill()
	bgm_player.stop()
	ambience_player.stop()
	sfx_player.stop()
	# 短暫延遲後播放刺殺音效（極低音量、極短）
	await get_tree().create_timer(0.8).timeout
	var stab_stream = _safe_load("res://audio/sfx/sword_stab.ogg")
	if stab_stream:
		sfx_player.stream = stab_stream
		sfx_player.volume_db = 7.0
		sfx_player.play()


## 輪迴重啟：音樂盒旋律
func play_loop_restart() -> void:
	await get_tree().create_timer(1.5).timeout  # 保持靜默片刻
	var music_box = _safe_load("res://audio/bgm/music_box_uneasy.ogg")
	if music_box:
		_crossfade_bgm(music_box, 3.0, -11.0)


## 調查場景 BGM
func play_investigation() -> void:
	var stream = _safe_load("res://audio/bgm/investigation.ogg")
	if stream:
		_crossfade_bgm(stream, 2.0, -11.0)


## 播放音效
func play_sfx(sfx_path: String) -> void:
	var stream = _safe_load(sfx_path)
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = 0.0
		sfx_player.play()


## 停止所有音樂
func stop_all() -> void:
	if _bgm_tween:
		_bgm_tween.kill()
	bgm_player.stop()
	sfx_player.stop()
	ambience_player.stop()


func _configure_dialogic_audio_routing() -> void:
	var current_defaults: Variant = ProjectSettings.get_setting("dialogic/audio/channel_defaults", {})
	var merged_defaults: Dictionary = {}
	if current_defaults is Dictionary:
		merged_defaults = current_defaults.duplicate(true)

	var changed := false
	for channel_name in DIALOGIC_AUDIO_CHANNEL_DEFAULTS.keys():
		var desired_defaults: Dictionary = DIALOGIC_AUDIO_CHANNEL_DEFAULTS[channel_name]
		var current_channel_defaults: Dictionary = {}
		var existing_channel_defaults: Variant = merged_defaults.get(channel_name, null)
		if existing_channel_defaults is Dictionary:
			current_channel_defaults = existing_channel_defaults.duplicate(true)

		for key in desired_defaults.keys():
			if current_channel_defaults.get(key) != desired_defaults[key]:
				current_channel_defaults[key] = desired_defaults[key]
				changed = true

		merged_defaults[channel_name] = current_channel_defaults

	if ProjectSettings.get_setting("dialogic/audio/type_sound_bus", "") != SFX_BUS_NAME:
		ProjectSettings.set_setting("dialogic/audio/type_sound_bus", SFX_BUS_NAME)
		changed = true

	if changed:
		ProjectSettings.set_setting("dialogic/audio/channel_defaults", merged_defaults)


func _safe_load(path: String) -> Resource:
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _crossfade_bgm(stream: AudioStream, duration: float = 1.0, target_volume_db: float = 0.0) -> void:
	if _bgm_tween:
		_bgm_tween.kill()
	if bgm_player.playing:
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(bgm_player, "volume_db", -40.0, duration * 0.5)
		await _bgm_tween.finished
	bgm_player.stream = stream
	bgm_player.volume_db = -40.0
	bgm_player.play()
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(bgm_player, "volume_db", target_volume_db, duration * 0.5)
