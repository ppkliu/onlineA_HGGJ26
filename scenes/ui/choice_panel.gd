extends PanelContainer

## 增強版選擇面板 — 鎖定選項灰色顯示 + 鎖頭圖示

signal choice_selected(choice_index: int)

@onready var choices_container: VBoxContainer = $VBoxContainer


## 設定選擇肢列表
## choices 格式: [{ "text": String, "locked": bool, "required_intels": Array[String] }]
func setup_choices(choices: Array) -> void:
	# 清除現有選項
	for child in choices_container.get_children():
		child.queue_free()

	for i in choices.size():
		var choice = choices[i]
		var button = Button.new()
		button.text = choice["text"]

		var is_locked = choice.get("locked", false)
		# 如果有情報需求，動態檢查
		if choice.has("required_intels"):
			is_locked = not IntelSystem.check_branch_condition(choice["required_intels"])

		if is_locked:
			button.text = "🔒 " + button.text
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 0.7)
		else:
			var idx = i
			button.pressed.connect(func(): _on_choice_pressed(idx))

		choices_container.add_child(button)


func _on_choice_pressed(index: int) -> void:
	choice_selected.emit(index)
	queue_free()
