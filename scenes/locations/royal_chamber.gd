extends Node2D


func _ready() -> void:
	# Let Dialogic handle story routing once we enter the correct phase entry.
	AudioManager.stop_all()
	FlowLogger.log_event("scene", "Royal chamber ready", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase], "loop": IntelSystem.current_loop})

	var timeline_id := _get_awakening_timeline()
	FlowLogger.log_event("dialogic", "Start timeline", {"timeline": timeline_id})
	IntelSystem.sync_to_dialogic()
	Dialogic.start(timeline_id)


func _get_awakening_timeline() -> String:
	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			return "00_early_phase_entry"
		LoopManager.LoopPhase.MID:
			return "01_loop3_entry_awakening"
		LoopManager.LoopPhase.FINAL:
			return "01_final_main_awakening"
		_:
			return "01_loop1_betrayal_awakening"
