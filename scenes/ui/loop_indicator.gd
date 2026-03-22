extends Control

## 輪迴次數指示器 — 畫面右上角顯示當前輪迴次數

const BRANCH_LABEL_FONT_SIZE := 18

@onready var loop_label: Label = %LoopLabel
@onready var branch_summary_label: Label = %BranchSummaryLabel
@onready var branch_list: VBoxContainer = %BranchList


func _ready() -> void:
	_update_display()
	LoopManager.loop_started.connect(_on_loop_started)
	IntelSystem.progression_updated.connect(_update_display)


func _on_loop_started(_loop_number: int) -> void:
	_update_display()


func _update_display() -> void:
	var loop_num = IntelSystem.current_loop
	if loop_num == 0:
		visible = false
	else:
		visible = true
		loop_label.text = "Loop %d" % loop_num
		branch_summary_label.text = "Completed Branches %d/2" % IntelSystem.get_completed_side_branch_count()
		_rebuild_branch_list()


func _rebuild_branch_list() -> void:
	for child in branch_list.get_children():
		child.queue_free()

	for branch in IntelSystem.get_branch_statuses():
		var label := Label.new()
		label.add_theme_font_size_override(&"font_size", BRANCH_LABEL_FONT_SIZE)
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
			return "[Done]"
		"available":
			return "[Open]"
		_:
			return "[Locked]"
