extends CanvasLayer

## 死亡畫面 — 顯示死因摘要 + 情報獲得動畫

signal animation_completed
signal continue_confirmed

const DEATH_MESSAGE_FONT_SIZE := 38
const INTEL_TITLE_FONT_SIZE := 30
const INTEL_DESC_FONT_SIZE := 24
const CONTINUE_FONT_SIZE := 28
const TEXT_OUTLINE_SIZE := 2
const TEXT_OUTLINE_COLOR := Color(0.05, 0.01, 0.01, 0.95)

@onready var background: ColorRect = $Background
@onready var death_message: Label = $CenterPanel/VBoxContainer/DeathMessage
@onready var intel_card_container: VBoxContainer = $CenterPanel/VBoxContainer/IntelCards
@onready var continue_label: Label = $CenterPanel/VBoxContainer/ContinueLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _context: Dictionary = {}
var _awaiting_continue := false


func setup(context: Dictionary) -> void:
	if not is_node_ready():
		await ready

	_context = context

	# 設定死因摘要
	var death_text = context.get("death_message", "你死了。")
	death_message.text = _normalize_display_text(death_text)
	_apply_text_overrides()

	# 顯示獲得的情報
	var rewards: Array = []
	if context.has("intel_reward"):
		if context["intel_reward"] is Array:
			rewards = context["intel_reward"]
		else:
			rewards = [context["intel_reward"]]

	for reward_id in rewards:
		if IntelSystem.acquired_intels.has(reward_id):
			var intel: IntelItem = IntelSystem.acquired_intels[reward_id]
			var card = _create_intel_card(intel)
			intel_card_container.add_child(card)

	# 播放動畫序列
	_play_sequence()


func _create_intel_card(intel: IntelItem) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.visible = false
	panel.custom_minimum_size = Vector2(0, 96)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.08, 0.08, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.92, 0.82, 0.72, 0.75)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override(&"panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 6)
	panel.add_child(vbox)

	var title_label = Label.new()
	title_label.text = "[ NEW ] " + intel.title
	title_label.add_theme_font_size_override(&"font_size", INTEL_TITLE_FONT_SIZE)
	title_label.add_theme_constant_override(&"outline_size", TEXT_OUTLINE_SIZE)
	title_label.add_theme_color_override(&"font_outline_color", TEXT_OUTLINE_COLOR)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	var desc_label = Label.new()
	desc_label.text = intel.description
	desc_label.add_theme_font_size_override(&"font_size", INTEL_DESC_FONT_SIZE)
	desc_label.add_theme_constant_override(&"outline_size", TEXT_OUTLINE_SIZE)
	desc_label.add_theme_color_override(&"font_outline_color", TEXT_OUTLINE_COLOR)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	return panel


func _play_sequence() -> void:
	# 淡入背景
	var tween = create_tween()
	background.modulate.a = 0.0
	tween.tween_property(background, "modulate:a", 1.0, 0.8)
	await tween.finished

	# 顯示死因
	death_message.visible = true
	await get_tree().create_timer(2.0).timeout

	# 逐一顯示情報卡片
	for card in intel_card_container.get_children():
		card.visible = true
		AudioManager.play_sfx("res://audio/sfx/intel_acquired.ogg")
		await get_tree().create_timer(1.5).timeout

	# 顯示繼續提示
	continue_label.visible = true
	continue_label.text = "按左鍵或確認，帶著新的知識回到過去……"
	await _wait_for_continue()

	animation_completed.emit()


func _normalize_display_text(value: Variant) -> String:
	var text := str(value)
	return text.replace("\\n", "\n")


func _apply_text_overrides() -> void:
	death_message.add_theme_font_size_override(&"font_size", DEATH_MESSAGE_FONT_SIZE)
	death_message.add_theme_constant_override(&"outline_size", TEXT_OUTLINE_SIZE)
	death_message.add_theme_color_override(&"font_outline_color", TEXT_OUTLINE_COLOR)
	continue_label.add_theme_font_size_override(&"font_size", CONTINUE_FONT_SIZE)
	continue_label.add_theme_constant_override(&"outline_size", TEXT_OUTLINE_SIZE)
	continue_label.add_theme_color_override(&"font_outline_color", TEXT_OUTLINE_COLOR)


func _wait_for_continue() -> void:
	_awaiting_continue = true
	await continue_confirmed


func _input(event: InputEvent) -> void:
	if not _awaiting_continue:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_confirm_continue()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("dialogic_default_action") or event.is_action_pressed("ui_accept"):
		_confirm_continue()
		get_viewport().set_input_as_handled()


func _confirm_continue() -> void:
	if not _awaiting_continue:
		return

	_awaiting_continue = false
	continue_confirmed.emit()
