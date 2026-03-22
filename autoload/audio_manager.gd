extends Node

## 音效管理器 — 三段式音樂設計 + Cut to Silence 效果

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer

var _bgm_tween: Tween


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.bus = "BGM"
	add_child(bgm_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)

	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "AmbiencePlayer"
	ambience_player.bus = "Ambience"
	add_child(ambience_player)


## 序章：史詩交響樂 + 大火音效
func play_prologue_epic() -> void:
	var bgm_stream = _safe_load("res://audio/bgm/prologue_epic.ogg")
	if bgm_stream:
		_crossfade_bgm(bgm_stream, 1.0, -7.0)
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
		_crossfade_bgm(music_box, 3.0, -6.0)


## 調查場景 BGM
func play_investigation() -> void:
	var stream = _safe_load("res://audio/bgm/investigation.ogg")
	if stream:
		_crossfade_bgm(stream, 2.0, -6.0)


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
