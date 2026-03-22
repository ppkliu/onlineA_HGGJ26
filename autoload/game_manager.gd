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


## 繼續遊戲（讀取手動存檔，讀取後刪除）
func continue_game() -> void:
	var save_path := "user://manual_save.json"
	if not FileAccess.file_exists(save_path):
		return

	var file := FileAccess.open(save_path, FileAccess.READ)
	var save_data: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if save_data is Dictionary:
		IntelSystem.reset_all()
		IntelSystem.current_loop = int(save_data.get("current_loop", 0))
		IntelSystem.tutorial_seen = save_data.get("tutorial_seen", false)
		for intel_id in save_data.get("acquired_intels", []):
			IntelSystem.acquire_intel(str(intel_id))

	# 讀取完畢，刪除存檔
	DirAccess.remove_absolute(save_path)
	FlowLogger.log_event("game", "Continue game from manual save", {"current_loop": IntelSystem.current_loop})

	change_state(GameState.PLAYING)
	if IntelSystem.current_loop == 0:
		SceneTransition.transition_to("res://scenes/game/game_scene.tscn",
			TransitionConstants.TransitionType.FADE_BLACK)
	else:
		SceneTransition.transition_to("res://scenes/locations/royal_chamber.tscn",
			TransitionConstants.TransitionType.FADE_BLACK)


## 返回主選單
func return_to_menu() -> void:
	change_state(GameState.MAIN_MENU)
	if Dialogic.current_timeline:
		Dialogic.end_timeline(true)
	AudioManager.stop_all()
	FlowLogger.log_event("game", "Return to menu")
	SceneTransition.transition_to("res://scenes/main_menu/main_menu.tscn",
		TransitionConstants.TransitionType.FADE_BLACK)


## 退出遊戲
func quit_game() -> void:
	get_tree().quit()


## 檢查是否有手動存檔
func has_save_data() -> bool:
	return FileAccess.file_exists("user://manual_save.json")


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
		"death_fade":
			FlowLogger.log_event("game", "Death fade effect triggered")
		"true_ending_reached":
			FlowLogger.log_event("game", "True ending reached")
		"show_credits":
			FlowLogger.log_event("game", "Show credits requested")
		_:
			if argument.begins_with("intel:"):
				var intel_id := argument.trim_prefix("intel:")
				IntelSystem.acquire_intel(intel_id)
			elif argument.begins_with("death_context:"):
				var payload := argument.trim_prefix("death_context:")
				var parsed: Variant = JSON.parse_string(payload.replace("'", '"'))
				if parsed is Dictionary:
					_pending_death_context = parsed
					if _pending_trigger_death:
						_trigger_death_with_pending_context()
				else:
					push_warning("Invalid death context payload: %s" % argument)
			elif argument.begins_with("camera_shake"):
				pass
			elif argument.begins_with("day_counter:"):
				var days := argument.trim_prefix("day_counter:").to_int()
				FlowLogger.log_event("game", "Day counter set", {"days": days})
			elif argument.begins_with("slow_motion_effect"):
				pass
			else:
				FlowLogger.log_event("dialogic", "Unhandled signal", {"argument": argument})


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
