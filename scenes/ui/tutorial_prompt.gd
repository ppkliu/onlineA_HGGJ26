extends Control

@export var auto_hide_delay := 8.0

@onready var panel: PanelContainer = $PanelContainer
@onready var timer: Timer = $HideTimer


func _ready() -> void:
	visible = false
	timer.wait_time = auto_hide_delay
	timer.timeout.connect(_hide_prompt)

	if IntelSystem.tutorial_seen:
		return

	visible = true
	timer.start()
	IntelSystem.mark_tutorial_seen()
	FlowLogger.log_event("tutorial", "Show first-time controls prompt")


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("dialogic_default_action") or event.is_action_pressed("open_journal"):
		_hide_prompt()


func _hide_prompt() -> void:
	if not visible:
		return
	visible = false
	timer.stop()
