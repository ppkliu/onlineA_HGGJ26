extends Node2D

## 公主寢宮 — 每次輪迴的起點場景


func _ready() -> void:
	AudioManager.play_loop_restart()
	FlowLogger.log_event("scene", "Royal chamber ready", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase], "loop": IntelSystem.current_loop})

	# 根據輪迴階段觸發不同的 Dialogic 時間線
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
