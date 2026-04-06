extends Control

## 劇情進度指示器 — 畫面右上角顯示「第幾幕」（依 LoopManager 階段，非輪迴數字）

const BRANCH_LABEL_FONT_SIZE := 18
const BRANCH_LABEL_MIN_HEIGHT := 28

@onready var loop_label: Label = %LoopLabel
@onready var branch_summary_label: Label = %BranchSummaryLabel
@onready var branch_list: VBoxContainer = %BranchList


func _ready() -> void:
	_update_display()
	LoopManager.loop_started.connect(_on_loop_started)
	LoopManager.loop_phase_changed.connect(_on_loop_phase_changed)
	IntelSystem.progression_updated.connect(_update_display)


func _on_loop_started(_loop_number: int) -> void:
	_update_display()


func _on_loop_phase_changed(_phase: StringName) -> void:
	_update_display()


func _update_display() -> void:
	var show_after_prologue := IntelSystem.has_prologue_cleared()
	if not show_after_prologue:
		visible = false
	else:
		visible = true
		loop_label.text = LoopManager.get_story_act_display()
		branch_summary_label.text = "已完成支線 %d/2" % IntelSystem.get_completed_side_branch_count()
		_rebuild_branch_list()


func _rebuild_branch_list() -> void:
	for child in branch_list.get_children():
		child.queue_free()

	for branch in IntelSystem.get_branch_statuses():
		var label := Label.new()
		label.add_theme_font_size_override(&"font_size", BRANCH_LABEL_FONT_SIZE)
		label.custom_minimum_size = Vector2(0, BRANCH_LABEL_MIN_HEIGHT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "%s %s" % [_status_prefix(branch["status"]), branch["title"]]
		match branch["status"]:
			"completed":
				label.modulate = Color(0.65, 0.95, 0.7)
			"available":
				label.modulate = Color(1.0, 0.9, 0.65)
			_:
				label.modulate = Color(0.6, 0.6, 0.65)
		branch_list.add_child(label)


func _status_prefix(status: String) -> String:
	match status:
		"completed":
			return "[完成]"
		"available":
			return "[可用]"
		_:
			return "[鎖定]"
