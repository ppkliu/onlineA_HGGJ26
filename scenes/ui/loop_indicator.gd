extends Control

## 輪迴次數指示器 — 畫面右上角顯示當前輪迴次數

@onready var loop_label: Label = $LoopLabel


func _ready() -> void:
	_update_display()
	LoopManager.loop_started.connect(_on_loop_started)


func _on_loop_started(_loop_number: int) -> void:
	_update_display()


func _update_display() -> void:
	var loop_num = IntelSystem.current_loop
	if loop_num == 0:
		visible = false
	else:
		visible = true
		loop_label.text = "Loop %d" % loop_num
