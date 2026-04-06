extends Node2D


func _ready() -> void:
	# 寢宮時間軸開頭已有 [music]；勿再 play_loop_restart，否則與 Dialogic 雙軌同一首 BGM 重疊。
	# 僅清掉序章／場景殘留的 AudioManager BGM。
	AudioManager.stop_all()
	FlowLogger.log_event("scene", "Royal chamber ready", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase], "loop": IntelSystem.current_loop})

	var timeline_id := _get_awakening_timeline()
	FlowLogger.log_event("dialogic", "Start timeline", {"timeline": timeline_id})
	IntelSystem.sync_to_dialogic()
	Dialogic.start(timeline_id)


func _get_awakening_timeline() -> String:
	match LoopManager.current_phase:
		LoopManager.LoopPhase.EARLY:
			return _get_early_timeline()
		LoopManager.LoopPhase.MID:
			return "01_awakening_cold"
		LoopManager.LoopPhase.FINAL:
			return "01_awakening_final"
		_:
			return "01_awakening"


## A 線依情報線性推進：A-0 → A-1 → A-2 → 第二章 B
func _get_early_timeline() -> String:
	if not IntelSystem.has_intel("intel_chancellor_betrayal"):
		return "01_awakening"                # A-0
	if not IntelSystem.has_intel("intel_fake_ledgers"):
		return "01_awakening_a_v1"           # A-1
	if not IntelSystem.has_intel("intel_chancellor_poison"):
		return "01_awakening_a_v2"           # A-2
	# A 線三份情報齊備 → 進入第二章 B 線
	if IntelSystem.has_intel("intel_mob_manipulation") and not IntelSystem.has_intel("intel_secret_passage"):
		return "b2_01_awakening"
	if IntelSystem.has_intel("intel_chancellor_surveillance") and not IntelSystem.has_intel("intel_mob_manipulation"):
		return "b1_01_awakening"
	return "01_awakening_angry"              # B-0（預設）
