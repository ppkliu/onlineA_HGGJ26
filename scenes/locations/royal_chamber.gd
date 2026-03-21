extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var background: Sprite2D = $Background
var _awakening_done: bool = false


func _ready() -> void:
	_fit_background_to_viewport()
	player.set_can_move(false)

	AudioManager.play_loop_restart()

	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			_play_timeline("res://dialogic/timelines/loop_1/awakening_cutscene.dtl")
		LoopManager.LoopPhase.MID:
			_play_timeline("res://dialogic/timelines/loop_2/awakening_with_intel.dtl")
		LoopManager.LoopPhase.FINAL:
			_play_timeline("res://dialogic/timelines/final_loop/final_confrontation.dtl")


func _fit_background_to_viewport() -> void:
	if background == null or background.texture == null:
		return
	var tex_size := background.texture.get_size()
	if tex_size.x <= 0 or tex_size.y <= 0:
		return
	var vp_size := get_viewport_rect().size
	var scale_factor := maxf(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
	background.scale = Vector2(scale_factor, scale_factor)
	background.position = vp_size / 2.0


func _play_timeline(path: String) -> void:
	Dialogic.start(path)
	Dialogic.timeline_ended.connect(_on_awakening_ended, CONNECT_ONE_SHOT)


func _on_awakening_ended() -> void:
	_awakening_done = true
	player.set_can_move(true)
