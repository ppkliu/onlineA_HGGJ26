extends Node2D

## 遊戲主場景容器 — 載入子場景 + 管理 Dialogic 對話層


func _ready() -> void:
	GameManager.change_state(GameManager.GameState.PLAYING)
	FlowLogger.log_event("scene", "Game scene ready", {"loop": IntelSystem.current_loop})

	# 序章開始
	if IntelSystem.current_loop == 0:
		_start_prologue()
	else:
		_start_loop()


func _start_prologue() -> void:
	AudioManager.play_prologue_epic()
	FlowLogger.log_event("dialogic", "Start timeline", {"timeline": "01_prologue_main"})
	var layout := Dialogic.start("01_prologue_main")
	if layout:
		print("[GameScene] Dialogic layout created: ", layout.name)
	else:
		push_error("[GameScene] Dialogic.start() returned null — no layout was created!")


func _start_loop() -> void:
	# 載入對應輪迴階段的場景
	FlowLogger.log_event("scene", "Start loop flow", {"phase": LoopManager.LoopPhase.keys()[LoopManager.current_phase]})
	SceneTransition.transition_to("res://scenes/locations/royal_chamber.tscn",
		SceneTransition.TransitionType.FADE_BLACK)
