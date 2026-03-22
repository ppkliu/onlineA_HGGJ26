extends Node

## 輪迴管理器 — 控制死亡、重生、場景重置的完整流程

signal loop_started(loop_number: int)
signal death_triggered(death_context: Dictionary)
signal loop_phase_changed(phase: StringName)

enum LoopPhase {
	PROLOGUE,       # 第 0 輪迴（序章）
	EARLY,          # 第 1-2 輪迴（摸索期）
	MID,            # 中期輪迴（推理期）
	FINAL,          # 最終輪迴
}

var current_phase: LoopPhase = LoopPhase.PROLOGUE
# 當前輪迴中的場景進度狀態（每次輪迴重置）
var scene_states: Dictionary = {}


func _ready() -> void:
	_update_phase()


## 觸發死亡 → 進入死亡畫面 → 獲得情報 → 輪迴重啟
func trigger_death(context: Dictionary = {}) -> void:
	# context 範例：{ "killer": "retainer", "intel_reward": "intel_001", "scene": "throne_room" }
	FlowLogger.log_event("death", "Trigger death", context)

	death_triggered.emit(context)

	# 1. 獲得此次死亡帶來的情報
	if context.has("intel_reward"):
		var rewards: Array = []
		if context["intel_reward"] is Array:
			rewards = context["intel_reward"]
		else:
			rewards = [context["intel_reward"]]
		for reward in rewards:
			IntelSystem.acquire_intel(reward)

	# 2. 顯示死亡畫面 + 情報獲得動畫（由 UI 層處理）
	await _show_death_screen(context)

	# 3. 執行輪迴重置（advance_loop: false 代表錯誤死法，不推進迴圈）
	var should_advance: bool = context.get("advance_loop", true)
	_reset_loop(should_advance)


## 輪迴重置
func _reset_loop(should_advance: bool = true) -> void:
	if should_advance:
		IntelSystem.trigger_loop_reset()
	scene_states.clear()
	_update_phase()
	loop_started.emit(IntelSystem.current_loop)
	FlowLogger.log_event("loop", "Reset loop scene state", {"loop": IntelSystem.current_loop, "phase": LoopPhase.keys()[current_phase], "advanced": should_advance})

	# 轉場到公主寢宮（輪迴起點）
	SceneTransition.transition_to("res://scenes/locations/royal_chamber.tscn",
		SceneTransition.TransitionType.LOOP_RESTART)


## 根據輪迴次數與關鍵情報更新階段
func _update_phase() -> void:
	var loop = IntelSystem.current_loop

	var old_phase = current_phase
	if loop == 0:
		current_phase = LoopPhase.PROLOGUE
	elif loop <= 2:
		current_phase = LoopPhase.EARLY
	elif IntelSystem.has_final_loop_requirements():
		current_phase = LoopPhase.FINAL
	else:
		current_phase = LoopPhase.MID

	if current_phase != old_phase:
		loop_phase_changed.emit(StringName(LoopPhase.keys()[current_phase]))

func _show_death_screen(context: Dictionary) -> void:
	var death_screen = load("res://scenes/ui/death_screen.tscn").instantiate()
	get_tree().root.add_child(death_screen)
	FlowLogger.log_event("ui", "Show death screen", context)
	death_screen.setup(context)
	await death_screen.animation_completed
	death_screen.queue_free()


## 設定場景狀態（用於追蹤當前輪迴內的一次性事件）
func set_scene_state(key: String, value: Variant) -> void:
	scene_states[key] = value


## 取得場景狀態
func get_scene_state(key: String, default: Variant = null) -> Variant:
	return scene_states.get(key, default)
