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
		tab_container.add_child(scroll)

		var vbox = VBoxContainer.new()
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

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	var title = Label.new()
	title.text = intel.title
	vbox.add_child(title)

	var desc = Label.new()
	desc.text = intel.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)

	return panel
