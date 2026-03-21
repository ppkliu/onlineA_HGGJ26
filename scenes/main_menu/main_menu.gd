extends Control

## 主選單場景

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	# 根據是否有存檔決定「繼續」按鈕是否可用
	continue_button.visible = GameManager.has_save_data()

	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_new_game_pressed() -> void:
	GameManager.start_new_game()


func _on_continue_pressed() -> void:
	GameManager.continue_game()


func _on_quit_pressed() -> void:
	GameManager.quit_game()
