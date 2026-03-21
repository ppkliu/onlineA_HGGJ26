extends Node2D

## 公主寢宮 — 每次輪迴的起點場景


func _ready() -> void:
	AudioManager.play_loop_restart()

	# 根據輪迴階段觸發不同的 Dialogic 時間線
	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			Dialogic.start("res://dialogic/timelines/loop_1/awakening.dtl")
		LoopManager.LoopPhase.MID:
			Dialogic.start("res://dialogic/timelines/loop_2/awakening_with_intel.dtl")
		LoopManager.LoopPhase.FINAL:
			Dialogic.start("res://dialogic/timelines/final_loop/final_confrontation.dtl")
