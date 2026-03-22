extends CanvasLayer

## 死亡畫面 — 顯示死因摘要 + 情報獲得動畫

signal animation_completed

@onready var background: ColorRect = $Background
@onready var death_message: Label = $VBoxContainer/DeathMessage
@onready var intel_card_container: VBoxContainer = $VBoxContainer/IntelCards
@onready var continue_label: Label = $VBoxContainer/ContinueLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _context: Dictionary = {}


func setup(context: Dictionary) -> void:
	_context = context

	# 設定死因摘要
	var death_text = context.get("death_message", "你死了。")
	death_message.text = _normalize_display_text(death_text)

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

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	var title_label = Label.new()
	title_label.text = "[ NEW ] " + intel.title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	var desc_label = Label.new()
	desc_label.text = intel.description
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
	continue_label.text = "帶著新的知識，回到過去……"
	await get_tree().create_timer(2.5).timeout

	animation_completed.emit()


func _normalize_display_text(value: Variant) -> String:
	var text := str(value)
	return text.replace("\\n", "\n")
