extends Control

## 情報日誌 UI — 分類顯示已獲得的情報

signal journal_closed

@onready var tab_container: TabContainer = $PanelContainer/TabContainer
@onready var close_button: Button = $PanelContainer/CloseButton

# 分類對應
const CATEGORIES = {
	&"character": "人物",
	&"conspiracy": "陰謀",
	&"general": "線索",
	&"truth": "真相",
}

var _is_open: bool = false


func _make_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.14, 0.18, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.95, 0.88, 0.68, 0.45)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	return style


func _ready() -> void:
	visible = false
	close_button.pressed.connect(_close)
	IntelSystem.intel_journal_updated.connect(_refresh)
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_journal"):
		if _is_open:
			_close()
		else:
			_open()


func _open() -> void:
	_is_open = true
	visible = true
	_refresh()
	GameManager.change_state(GameManager.GameState.PAUSED)


func _close() -> void:
	_is_open = false
	visible = false
	journal_closed.emit()
	GameManager.change_state(GameManager.GameState.PLAYING)


func _refresh() -> void:
	# 清除現有頁籤內容
	for child in tab_container.get_children():
		child.queue_free()

	# 按分類建立頁籤
	for category_key in CATEGORIES:
		var scroll = ScrollContainer.new()
		scroll.name = CATEGORIES[category_key]
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		tab_container.add_child(scroll)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override(&"separation", 10)
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(vbox)

		# 填入該分類的情報
		for intel_id in IntelSystem.acquired_intels:
			var intel: IntelItem = IntelSystem.acquired_intels[intel_id]
			if intel.category == category_key:
				var card = _create_card(intel)
				vbox.add_child(card)


func _create_card(intel: IntelItem) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 110)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(&"panel", _make_card_style())

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 6)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = intel.title
	title.add_theme_font_size_override(&"font_size", 24)
	vbox.add_child(title)

	var desc = Label.new()
	desc.text = intel.description
	desc.add_theme_font_size_override(&"font_size", 20)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)

	return panel
