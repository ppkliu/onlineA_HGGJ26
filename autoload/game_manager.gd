extends Node

## 遊戲全局管理器 — 控制遊戲狀態、主選單邏輯

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	DEATH_SCREEN,
}

var current_state: GameState = GameState.MAIN_MENU
var _pending_death_context: Dictionary = {}
var _pending_trigger_death := false

signal game_state_changed(new_state: GameState)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Dialogic and not Dialogic.signal_event.is_connected(_on_dialogic_signal_event):
		Dialogic.signal_event.connect(_on_dialogic_signal_event)
	FlowLogger.log_event("game", "GameManager ready")


func change_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)
	FlowLogger.log_event("game", "Change state", {"state": GameState.keys()[new_state]})

	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		_:
			get_tree().paused = false


## 開始新遊戲
func start_new_game() -> void:
	IntelSystem.reset_all()
	FlowLogger.clear()
	FlowLogger.log_event("game", "Start new game")
	change_state(GameState.PLAYING)
	SceneTransition.transition_to("res://scenes/game/game_scene.tscn",
		TransitionConstants.TransitionType.FADE_BLACK)


## 繼續遊戲
func continue_game() -> void:
	FlowLogger.log_event("game", "Continue game", {"current_loop": IntelSystem.current_loop})
	change_state(GameState.PLAYING)
	# IntelSystem 在 _ready 中已自動載入存檔
	if IntelSystem.current_loop == 0:
		# 沒有存檔，從序章開始
		SceneTransition.transition_to("res://scenes/game/game_scene.tscn",
			TransitionConstants.TransitionType.FADE_BLACK)
	else:
		# 有存檔，從輪迴起點開始
		SceneTransition.transition_to("res://scenes/locations/royal_chamber.tscn",
			TransitionConstants.TransitionType.FADE_BLACK)


## 返回主選單
func return_to_menu() -> void:
	change_state(GameState.MAIN_MENU)
	AudioManager.stop_all()
	FlowLogger.log_event("game", "Return to menu")
	SceneTransition.transition_to("res://scenes/main_menu/main_menu.tscn",
		TransitionConstants.TransitionType.FADE_BLACK)


## 退出遊戲
func quit_game() -> void:
	get_tree().quit()


## 檢查是否有存檔
func has_save_data() -> bool:
	return FileAccess.file_exists("user://break_the_loop_save.json")


func _on_dialogic_signal_event(argument: Variant) -> void:
	FlowLogger.log_event("dialogic", "Received signal event", {"argument": argument})
	if argument is Dictionary:
		_handle_dialogic_signal_dict(argument)
	elif argument is String:
		_handle_dialogic_signal_string(argument)


func _handle_dialogic_signal_string(argument: String) -> void:
	match argument:
		"cut_to_silence":
			AudioManager.cut_to_silence()
		"trigger_death":
			if _pending_death_context.is_empty():
				_pending_trigger_death = true
			else:
				_trigger_death_with_pending_context()
		"camera_shake":
			pass
		_:
			if argument.begins_with("death_context:"):
				var payload := argument.trim_prefix("death_context:")
				var parsed: Variant = JSON.parse_string(payload.replace("'", '"'))
				if parsed is Dictionary:
					_pending_death_context = parsed
					if _pending_trigger_death:
						_trigger_death_with_pending_context()
				else:
					push_warning("Invalid death context payload: %s" % argument)


func _handle_dialogic_signal_dict(argument: Dictionary) -> void:
	match argument.get("action", ""):
		"trigger_death":
			LoopManager.trigger_death(argument)
		"cut_to_silence":
			AudioManager.cut_to_silence()


func _trigger_death_with_pending_context() -> void:
	var context := _pending_death_context.duplicate(true)
	_pending_death_context.clear()
	_pending_trigger_death = false
	LoopManager.trigger_death(context)
