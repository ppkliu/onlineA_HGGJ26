extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var background: Sprite2D = $Background
var _awakening_done: bool = false


func _ready() -> void:
	_fit_background_to_viewport()
	player.set_can_move(false)

	AudioManager.play_loop_restart()
	FlowLogger.log_event("scene", "Royal chamber ready", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase], "loop": IntelSystem.current_loop})

	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			FlowLogger.log_event("dialogic", "Start timeline", {"timeline": "awakening"})
			Dialogic.start("res://dialogic/timelines/loop_1/awakening.dtl")
		LoopManager.LoopPhase.MID:
			FlowLogger.log_event("dialogic", "Start timeline", {"timeline": "awakening_with_intel"})
			Dialogic.start("res://dialogic/timelines/loop_2/awakening_with_intel.dtl")
		LoopManager.LoopPhase.FINAL:
			FlowLogger.log_event("dialogic", "Start timeline", {"timeline": "final_confrontation"})
			Dialogic.start("res://dialogic/timelines/final_loop/final_confrontation.dtl")
