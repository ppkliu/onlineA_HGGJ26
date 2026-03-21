extends Node2D

@onready var player: CharacterBody2D = $Player
var _awakening_done: bool = false


func _ready() -> void:
	player.set_can_move(false)

	AudioManager.play_loop_restart()

	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			_play_timeline("res://dialogic/timelines/loop_1/awakening_cutscene.dtl")
		LoopManager.LoopPhase.MID:
			_play_timeline("res://dialogic/timelines/loop_2/awakening_with_intel.dtl")
		LoopManager.LoopPhase.FINAL:
			_play_timeline("res://dialogic/timelines/final_loop/final_confrontation.dtl")


func _play_timeline(path: String) -> void:
	Dialogic.start(path)
	Dialogic.timeline_ended.connect(_on_awakening_ended, CONNECT_ONE_SHOT)


func _on_awakening_ended() -> void:
	_awakening_done = true
	player.set_can_move(true)
