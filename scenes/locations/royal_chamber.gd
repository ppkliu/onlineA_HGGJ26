extends Node2D


func _ready() -> void:
	# Start either the forced handoff timeline from the previous death or the default phase entry.
	AudioManager.stop_all()
	FlowLogger.log_event("scene", "Royal chamber ready", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase], "loop": IntelSystem.current_loop})

	var timeline_id := _get_awakening_timeline()
	FlowLogger.log_event("dialogic", "Start timeline", {"timeline": timeline_id})
	IntelSystem.sync_to_dialogic()
	Dialogic.start(timeline_id)


func _get_awakening_timeline() -> String:
	var pending_timeline := LoopManager.consume_pending_next_timeline()
	if not pending_timeline.is_empty():
		return pending_timeline

	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			return "01_loop1_betrayal_awakening"
		LoopManager.LoopPhase.MID:
			return "01_loop3_dal_awakening"
		LoopManager.LoopPhase.FINAL:
			return "01_final_main_awakening"
		_:
			return "01_loop1_betrayal_awakening"
