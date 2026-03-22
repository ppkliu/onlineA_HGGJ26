extends CanvasLayer

## ESC 選單 + 右鍵加速對話
## 功能：字型大小、對話速度、對話框透明度、加速倍率、儲存紀錄、回到首頁

const SAVE_DIR := "user://manual_saves/"
const MAX_SAVES := 3

var _is_open := false
var _save_count := 0
var _is_fast_forwarding := false
## Dialogic text_speed 是乘數: 1.0=正常, 0.5=2倍快, 數字越小越快
var _normal_text_speed := 1.0
var _fast_forward_multiplier := 6.0
## 右鍵按住時的自動推進計時器
var _ff_advance_timer: Timer

@onready var panel: PanelContainer = %Panel
@onready var font_size_slider: HSlider = %FontSizeSlider
@onready var font_size_label: Label = %FontSizeValue
@onready var speed_slider: HSlider = %SpeedSlider
@onready var speed_label: Label = %SpeedValue
@onready var opacity_slider: HSlider = %OpacitySlider
@onready var opacity_label: Label = %OpacityValue
@onready var fast_forward_slider: HSlider = %FastForwardSlider
@onready var fast_forward_label: Label = %FastForwardValue
@onready var save_button: Button = %SaveButton
@onready var save_count_label: Label = %SaveCountLabel
@onready var resume_button: Button = %ResumeButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_ensure_save_dir()
	_count_existing_saves()

	font_size_slider.value = _get_current_font_size()
	font_size_label.text = str(int(font_size_slider.value))
	_normal_text_speed = _get_current_speed()
	speed_slider.value = _normal_text_speed
	speed_label.text = "%.1f" % speed_slider.value
	opacity_slider.value = _get_current_opacity()
	opacity_label.text = "%d%%" % int(opacity_slider.value * 100)
	fast_forward_slider.value = _fast_forward_multiplier
	fast_forward_label.text = "%.1fx" % _fast_forward_multiplier
	_update_save_button()

	# 右鍵自動推進計時器
	_ff_advance_timer = Timer.new()
	_ff_advance_timer.wait_time = 0.15
	_ff_advance_timer.one_shot = false
	_ff_advance_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	_ff_advance_timer.timeout.connect(_on_ff_advance_tick)
	add_child(_ff_advance_timer)

	font_size_slider.value_changed.connect(_on_font_size_changed)
	speed_slider.value_changed.connect(_on_speed_changed)
	opacity_slider.value_changed.connect(_on_opacity_changed)
	fast_forward_slider.value_changed.connect(_on_fast_forward_changed)
	save_button.pressed.connect(_on_save_pressed)
	resume_button.pressed.connect(close_menu)
	menu_button.pressed.connect(_on_menu_pressed)


func _exit_tree() -> void:
	if _is_fast_forwarding:
		_stop_fast_forward()


func _input(event: InputEvent) -> void:
	# ESC 開關選單
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _is_open:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()
		return

	# 右鍵按住 = 加速對話並自動推進
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and not _is_open:
			_start_fast_forward()
		elif not event.pressed and _is_fast_forwarding:
			_stop_fast_forward()
		get_viewport().set_input_as_handled()


func open_menu() -> void:
	if _is_open:
		return
	if _is_fast_forwarding:
		_stop_fast_forward()
	_is_open = true
	visible = true
	get_tree().paused = true


func close_menu() -> void:
	if not _is_open:
		return
	_is_open = false
	visible = false
	get_tree().paused = false


## ── 右鍵加速 ─────────────────────────────────────

func _start_fast_forward() -> void:
	_is_fast_forwarding = true
	# 加速文字顯示
	var fast_speed := _normal_text_speed / _fast_forward_multiplier
	_apply_text_speed(fast_speed)
	# 啟用 auto_skip 讓 wait 事件也加速（不跳過，縮短等待時間）
	if Dialogic and Dialogic.has_subsystem("Inputs"):
		Dialogic.Inputs.auto_skip.disable_on_user_input = false
		Dialogic.Inputs.auto_skip.time_per_event = 0.01
		Dialogic.Inputs.auto_skip.enabled = true
	# 立刻推進一次，然後開始持續推進
	_try_advance_dialog()
	_ff_advance_timer.start()


func _stop_fast_forward() -> void:
	_is_fast_forwarding = false
	_ff_advance_timer.stop()
	_apply_text_speed(_normal_text_speed)
	# 關閉 auto_skip
	if Dialogic and Dialogic.has_subsystem("Inputs"):
		Dialogic.Inputs.auto_skip.enabled = false
		Dialogic.Inputs.auto_skip.disable_on_user_input = true


func _on_ff_advance_tick() -> void:
	if _is_fast_forwarding:
		_try_advance_dialog()
	else:
		_ff_advance_timer.stop()


func _try_advance_dialog() -> void:
	if Dialogic and Dialogic.has_subsystem("Inputs"):
		Dialogic.Inputs.handle_input()


func _apply_text_speed(multiplier: float) -> void:
	if Dialogic:
		# 直接寫入 settings dict 並觸發 change callback
		Dialogic.Settings.settings["text_speed"] = multiplier
		Dialogic.Settings._setting_changed("text_speed", multiplier)


## ── 字型大小 ──────────────────────────────────────

func _get_current_font_size() -> float:
	if DialogicCustomizer:
		return DialogicCustomizer.get_current_font_size() as float
	var vp_h := get_viewport().get_visible_rect().size.y
	return round(vp_h * 0.25 / 3.0)


func _on_font_size_changed(value: float) -> void:
	font_size_label.text = str(int(value))
	if DialogicCustomizer:
		DialogicCustomizer.set_font_size(int(value))


## ── 對話速度 ──────────────────────────────────────
## 滑桿值 = 乘數 (0.2=5倍快, 0.5=2倍快, 1.0=正常, 2.0=2倍慢)

func _get_current_speed() -> float:
	if Dialogic:
		return Dialogic.Settings.get_setting("text_speed", 1.0) as float
	return 1.0


func _on_speed_changed(value: float) -> void:
	speed_label.text = "%.1f" % value
	_normal_text_speed = value
	if not _is_fast_forwarding:
		_apply_text_speed(value)


## ── 加速倍率 ──────────────────────────────────────

func _on_fast_forward_changed(value: float) -> void:
	_fast_forward_multiplier = value
	fast_forward_label.text = "%.1fx" % value


## ── 對話框透明度 ──────────────────────────────────

func _get_current_opacity() -> float:
	return DialogicCustomizer.BOX_OPACITY if DialogicCustomizer else 0.5


func _on_opacity_changed(value: float) -> void:
	opacity_label.text = "%d%%" % int(value * 100)
	if DialogicCustomizer:
		DialogicCustomizer.set_box_opacity(value)


## ── 儲存紀錄 ──────────────────────────────────────

func _on_save_pressed() -> void:
	if _save_count >= MAX_SAVES:
		return

	_save_count += 1
	var save_data := {
		"current_loop": IntelSystem.current_loop,
		"acquired_intels": IntelSystem.acquired_intels.duplicate(),
		"tutorial_seen": IntelSystem.tutorial_seen,
		"timestamp": Time.get_datetime_string_from_system(),
	}

	var path := SAVE_DIR + "save_%d.json" % _save_count
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		FlowLogger.log_event("save", "Manual save created", {"slot": _save_count})

	_update_save_button()


func _update_save_button() -> void:
	save_count_label.text = "(%d/%d)" % [_save_count, MAX_SAVES]
	save_button.disabled = _save_count >= MAX_SAVES


## ── 回到首頁 ──────────────────────────────────────

func _on_menu_pressed() -> void:
	close_menu()
	GameManager.return_to_menu()


## ── 輔助 ─────────────────────────────────────────

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _count_existing_saves() -> void:
	_save_count = 0
	var dir := DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.begins_with("save_") and file_name.ends_with(".json"):
				_save_count += 1
			file_name = dir.get_next()
		dir.list_dir_end()


