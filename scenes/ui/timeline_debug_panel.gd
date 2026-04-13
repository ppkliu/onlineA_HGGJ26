extends CanvasLayer

const STATUS_ACTIVE := "進行中"
const STATUS_PENDING := "待播"
const STATUS_ENTRY := "當前入口"
const STATUS_AVAILABLE := "可跳轉"
const STATUS_PREVIOUS := "較早章節"
const STATUS_LOCKED := "未解鎖"

@onready var panel: PanelContainer = %Panel
@onready var phase_label: Label = %PhaseLabel
@onready var current_label: Label = %CurrentLabel
@onready var pending_label: Label = %PendingLabel
@onready var search_input: LineEdit = %SearchInput
@onready var count_label: Label = %CountLabel
@onready var list_container: VBoxContainer = %TimelineList

var _is_open := false
var _timeline_cache: Array[Dictionary] = []


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	search_input.text_changed.connect(_on_search_changed)

	if Dialogic:
		if not Dialogic.timeline_started.is_connected(_on_timeline_state_changed):
			Dialogic.timeline_started.connect(_on_timeline_state_changed)
		if not Dialogic.timeline_ended.is_connected(_on_timeline_state_changed):
			Dialogic.timeline_ended.connect(_on_timeline_state_changed)

	if IntelSystem and not IntelSystem.progression_updated.is_connected(_on_progression_updated):
		IntelSystem.progression_updated.connect(_on_progression_updated)

	if LoopManager:
		if not LoopManager.loop_phase_changed.is_connected(_on_loop_phase_changed):
			LoopManager.loop_phase_changed.connect(_on_loop_phase_changed)
		if not LoopManager.loop_started.is_connected(_on_loop_started):
			LoopManager.loop_started.connect(_on_loop_started)

	_refresh_timeline_cache()
	_refresh_panel()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_T:
		if _is_open:
			close_panel()
		else:
			open_panel()
		get_viewport().set_input_as_handled()


func open_panel() -> void:
	_is_open = true
	visible = true
	_refresh_timeline_cache()
	_refresh_panel()
	search_input.grab_focus()


func close_panel() -> void:
	_is_open = false
	visible = false


func _on_search_changed(_value: String) -> void:
	_refresh_panel()


func _on_timeline_state_changed() -> void:
	_refresh_panel()


func _on_progression_updated() -> void:
	_refresh_panel()


func _on_loop_phase_changed(_phase: StringName) -> void:
	_refresh_panel()


func _on_loop_started(_loop_number: int) -> void:
	_refresh_panel()


func _refresh_timeline_cache() -> void:
	_timeline_cache.clear()
	var timeline_directory: Dictionary = DialogicResourceUtil.get_timeline_directory()
	for identifier_variant in timeline_directory.keys():
		var identifier := String(identifier_variant)
		var path := String(timeline_directory.get(identifier, ""))
		_timeline_cache.append({
			"id": identifier,
			"path": path,
			"phase_index": _extract_phase_index(path),
			"group_name": _extract_group_name(path),
			"folder_name": path.get_base_dir().get_file(),
			"file_name": path.get_file(),
		})

	_timeline_cache.sort_custom(_compare_timelines)


func _refresh_panel() -> void:
	if not is_node_ready():
		return

	phase_label.text = "章節: %s" % LoopManager.get_story_act_display()
	current_label.text = "目前: %s" % _get_current_timeline_id()

	var pending_timeline := LoopManager.peek_pending_next_timeline()
	pending_label.text = "待播: %s" % (pending_timeline if not pending_timeline.is_empty() else "無")

	for child in list_container.get_children():
		child.queue_free()

	var filter_text := search_input.text.strip_edges().to_lower()
	var visible_count := 0
	for timeline in _timeline_cache:
		if not _matches_filter(timeline, filter_text):
			continue
		list_container.add_child(_build_timeline_row(timeline))
		visible_count += 1

	count_label.text = "顯示 %d / %d" % [visible_count, _timeline_cache.size()]


func _build_timeline_row(timeline: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	var status_label := Label.new()
	status_label.custom_minimum_size = Vector2(96, 0)
	status_label.text = _get_timeline_status(timeline)
	status_label.modulate = _get_status_color(status_label.text)
	row.add_child(status_label)

	var id_label := Label.new()
	id_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_label.text = String(timeline["id"])
	id_label.clip_text = true
	row.add_child(id_label)

	var group_label := Label.new()
	group_label.custom_minimum_size = Vector2(92, 0)
	group_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	group_label.text = String(timeline["group_name"])
	group_label.modulate = Color(0.78, 0.78, 0.84)
	row.add_child(group_label)

	var jump_button := Button.new()
	jump_button.text = "跳轉"
	jump_button.pressed.connect(_jump_to_timeline.bind(String(timeline["id"])))
	row.add_child(jump_button)

	return row


func _jump_to_timeline(timeline_id: String) -> void:
	if Dialogic.current_timeline:
		Dialogic.end_timeline()

	IntelSystem.sync_to_dialogic()
	FlowLogger.log_event("debug", "Jump timeline", {"timeline": timeline_id})
	Dialogic.start(timeline_id)
	_refresh_panel()


func _matches_filter(timeline: Dictionary, filter_text: String) -> bool:
	if filter_text.is_empty():
		return true

	var haystacks := [
		String(timeline["id"]).to_lower(),
		String(timeline["path"]).to_lower(),
		String(timeline["group_name"]).to_lower(),
		_get_timeline_status(timeline).to_lower(),
	]
	for text in haystacks:
		if text.contains(filter_text):
			return true
	return false


func _get_timeline_status(timeline: Dictionary) -> String:
	var timeline_id := String(timeline["id"])
	var current_timeline_id := _get_current_timeline_id()
	if timeline_id == current_timeline_id:
		return STATUS_ACTIVE

	var pending_timeline := LoopManager.peek_pending_next_timeline()
	if timeline_id == pending_timeline:
		return STATUS_PENDING

	var default_timeline := GameManager.get_default_story_timeline_id()
	if timeline_id == default_timeline:
		return STATUS_ENTRY

	var timeline_phase_index := int(timeline.get("phase_index", 99))
	var current_phase_index := LoopManager.get_current_phase_index()
	if timeline_phase_index > current_phase_index:
		return STATUS_LOCKED
	if timeline_phase_index < current_phase_index:
		return STATUS_PREVIOUS
	return STATUS_AVAILABLE


func _get_status_color(status: String) -> Color:
	match status:
		STATUS_ACTIVE:
			return Color(0.52, 0.96, 0.6)
		STATUS_PENDING:
			return Color(0.98, 0.82, 0.4)
		STATUS_ENTRY:
			return Color(0.55, 0.86, 1.0)
		STATUS_AVAILABLE:
			return Color(0.92, 0.92, 0.92)
		STATUS_PREVIOUS:
			return Color(0.72, 0.72, 0.82)
		_:
			return Color(0.7, 0.48, 0.48)


func _get_current_timeline_id() -> String:
	if Dialogic == null or Dialogic.current_timeline == null:
		return "無"

	var path := String(Dialogic.current_timeline.resource_path)
	var identifier := DialogicResourceUtil.get_unique_identifier_by_path(path)
	if not identifier.is_empty():
		return identifier
	return path.get_file().trim_suffix(".dtl")


func _extract_phase_index(path: String) -> int:
	var folder_name := path.get_base_dir().get_file()
	var prefix := folder_name.split("_", false, 1)[0]
	if prefix.is_valid_int():
		return prefix.to_int()
	return 99


func _extract_group_name(path: String) -> String:
	var folder_name := path.get_base_dir().get_file()
	return folder_name.trim_prefix("%02d_" % _extract_phase_index(path)).replace("_", " ").capitalize()


func _compare_timelines(a: Dictionary, b: Dictionary) -> bool:
	var a_phase := int(a.get("phase_index", 99))
	var b_phase := int(b.get("phase_index", 99))
	if a_phase != b_phase:
		return a_phase < b_phase

	var a_folder := String(a.get("folder_name", ""))
	var b_folder := String(b.get("folder_name", ""))
	if a_folder != b_folder:
		return a_folder.naturalnocasecmp_to(b_folder) < 0

	var a_file := String(a.get("file_name", ""))
	var b_file := String(b.get("file_name", ""))
	if a_file != b_file:
		return a_file.naturalnocasecmp_to(b_file) < 0

	return String(a.get("id", "")).naturalnocasecmp_to(String(b.get("id", ""))) < 0
