extends Node2D


func _ready() -> void:
	AudioManager.play_loop_restart()
	FlowLogger.log_event("scene", "Royal chamber ready", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase], "loop": IntelSystem.current_loop})

	var timeline_id := _get_awakening_timeline()
	FlowLogger.log_event("dialogic", "Start timeline", {"timeline": timeline_id})
	Dialogic.start(timeline_id)


func _get_awakening_timeline() -> String:
	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			if IntelSystem.current_loop <= 1:
				return "01_awakening"
			else:
				return "01_awakening_angry"
		LoopManager.LoopPhase.MID:
			return "01_awakening_cold"
		LoopManager.LoopPhase.FINAL:
			return "01_awakening_final"
		_:
			return "01_awakening"
