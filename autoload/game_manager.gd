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

signal game_state_changed(new_state: GameState)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)

	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		_:
			get_tree().paused = false


## 開始新遊戲
func start_new_game() -> void:
	IntelSystem.reset_all()
	change_state(GameState.PLAYING)
	SceneTransition.transition_to("res://scenes/game/game_scene.tscn",
		SceneTransition.TransitionType.FADE_BLACK)


## 繼續遊戲
func continue_game() -> void:
	change_state(GameState.PLAYING)
	# IntelSystem 在 _ready 中已自動載入存檔
	if IntelSystem.current_loop == 0:
		# 沒有存檔，從序章開始
		SceneTransition.transition_to("res://scenes/game/game_scene.tscn",
			SceneTransition.TransitionType.FADE_BLACK)
	else:
		# 有存檔，從輪迴起點開始
		SceneTransition.transition_to("res://scenes/locations/royal_chamber.tscn",
			SceneTransition.TransitionType.FADE_BLACK)


## 返回主選單
func return_to_menu() -> void:
	change_state(GameState.MAIN_MENU)
	AudioManager.stop_all()
	SceneTransition.transition_to("res://scenes/main_menu/main_menu.tscn",
		SceneTransition.TransitionType.FADE_BLACK)


## 退出遊戲
func quit_game() -> void:
	get_tree().quit()


## 檢查是否有存檔
func has_save_data() -> bool:
	return FileAccess.file_exists("user://break_the_loop_save.json")
