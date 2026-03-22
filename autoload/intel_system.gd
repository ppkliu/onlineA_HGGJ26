extends Node

## 情報繼承系統 — 跨輪迴持久化的全域情報管理器
##
## 設計原則：
## - 情報一旦獲得，永不消失（即使輪迴重置）
## - 情報 ID 對應 Dialogic 條件分支
## - 支援存檔到磁碟（因為移除了 S/L，改用自動存檔）

signal intel_acquired(intel_id: String)
signal intel_journal_updated()
signal progression_updated()

# 已獲得的情報集合 { intel_id: IntelItem }
var acquired_intels: Dictionary = {}

# 已造訪的選項 { choice_text: true }
var visited_choices: Dictionary = {}

# 當前輪迴次數
var current_loop: int = 0
var tutorial_seen: bool = false
var save_path := "user://break_the_loop_save.json"

# 情報資料庫（從 Resource 載入）
var _intel_database: Dictionary = {}

const BRANCH_DEFINITIONS := [
	{
		"id": "loop_1",
		"title": "第一輪迴：被操弄的正義",
		"required_intels": [],
		"completed_intels": ["intel_chancellor_betrayal", "intel_fake_ledgers", "intel_chancellor_poison"],
	},
	{
		"id": "loop_2",
		"title": "第二輪迴：民心之刃",
		"required_intels": ["intel_chancellor_betrayal"],
		"completed_intels": ["intel_mob_manipulation", "intel_starvation_real", "intel_bruno_wife_death"],
	},
	{
		"id": "loop_3",
		"title": "第三輪迴：棋差一步",
		"required_intels": ["intel_mob_manipulation"],
		"completed_intels": ["intel_chancellor_treason", "intel_king_defense_line", "intel_dal_blinded_by_chancellor"],
	},
	{
		"id": "final_loop",
		"title": "最終輪迴：破曉",
		"required_intels": ["intel_chancellor_treason", "intel_king_defense_line"],
		"completed_intels": [],
	},
]


func _ready() -> void:
	_load_intel_database()
	_load_persistent_data()
	_emit_progression_updated()
	call_deferred("sync_to_dialogic")


## 載入情報資料庫定義
func _load_intel_database() -> void:
	var db = load("res://resources/intel_data/intel_database.tres")
	if db:
		for item in db.items:
			_intel_database[item.id] = item


## 獲得新情報
func acquire_intel(intel_id: String) -> bool:
	if acquired_intels.has(intel_id):
		return false  # 已經擁有

	if not _intel_database.has(intel_id):
		push_warning("未知的情報 ID: %s" % intel_id)
		return false

	acquired_intels[intel_id] = _intel_database[intel_id]
	intel_acquired.emit(intel_id)
	intel_journal_updated.emit()
	sync_to_dialogic()
	_save_persistent_data()
	_emit_progression_updated()
	FlowLogger.log_event("intel", "Acquired intel", {"intel_id": intel_id})
	return true


## 檢查是否擁有特定情報（供 Dialogic 條件使用）
func has_intel(intel_id: String) -> bool:
	return acquired_intels.has(intel_id)


## 檢查是否滿足分支解鎖條件（多情報 AND 邏輯）
func check_branch_condition(required_intels: Array[String]) -> bool:
	for id in required_intels:
		if not has_intel(id):
			return false
	return true


## 輪迴重置 — 保留情報、重置場景狀態
func trigger_loop_reset() -> void:
	current_loop += 1
	_save_persistent_data()
	_emit_progression_updated()
	FlowLogger.log_event("loop", "Loop reset triggered", {"current_loop": current_loop})
	# 情報不重置！只重置場景相關狀態


## 記錄造訪過的選項
func mark_choice_visited(choice_text: String) -> void:
	if not visited_choices.has(choice_text):
		visited_choices[choice_text] = true
		_save_persistent_data()


## 檢查選項是否造訪過
func is_choice_visited(choice_text: String) -> bool:
	return visited_choices.has(choice_text)


## 持久化存檔（自動存檔，非手動 S/L）
func _save_persistent_data() -> void:
	var save_data = {
		"current_loop": current_loop,
		"acquired_intels": acquired_intels.keys(),
		"tutorial_seen": tutorial_seen,
		"visited_choices": visited_choices.keys(),
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))


## 讀取持久化資料
func _load_persistent_data() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if data:
			current_loop = data.get("current_loop", 0)
			tutorial_seen = data.get("tutorial_seen", false)
			for id in data.get("acquired_intels", []):
				if _intel_database.has(id):
					acquired_intels[id] = _intel_database[id]
			for choice_text in data.get("visited_choices", []):
				visited_choices[choice_text] = true
	_emit_progression_updated()


## 將情報狀態同步到 Dialogic 變數（供 Dialogic 條件分支使用）
func sync_to_dialogic() -> void:
	if not is_inside_tree():
		return
	var dialogic_node := get_node_or_null("/root/Dialogic")
	if dialogic_node == null:
		return
	for id in _intel_database.keys():
		Dialogic.VAR.set(id, false)
	for id in acquired_intels.keys():
		Dialogic.VAR.set(id, true)


## 完全重置（新遊戲）
func reset_all() -> void:
	acquired_intels.clear()
	visited_choices.clear()
	current_loop = 0
	tutorial_seen = false
	_save_persistent_data()
	_emit_progression_updated()
	FlowLogger.log_event("intel", "Reset all intel and tutorial state")


func mark_tutorial_seen() -> void:
	if tutorial_seen:
		return
	tutorial_seen = true
	_save_persistent_data()
	_emit_progression_updated()
	FlowLogger.log_event("tutorial", "Marked tutorial as seen")


func get_branch_statuses() -> Array:
	var statuses: Array = []
	for branch in BRANCH_DEFINITIONS:
		var required_intels: Array[String] = []
		for intel_id: String in branch.get("required_intels", []):
			required_intels.append(intel_id)

		var completed_intels: Array[String] = []
		for intel_id: String in branch.get("completed_intels", []):
			completed_intels.append(intel_id)

		var is_completed := false
		for intel_id in completed_intels:
			if has_intel(intel_id):
				is_completed = true
				break

		var is_unlocked := required_intels.is_empty() or check_branch_condition(required_intels)
		var status := "locked"
		if is_completed:
			status = "completed"
		elif is_unlocked:
			status = "available"

		statuses.append({
			"id": branch["id"],
			"title": branch["title"],
			"status": status,
			"required_intels": required_intels,
		})
	return statuses


func get_completed_side_branch_count() -> int:
	var completed := 0
	for branch in get_branch_statuses():
		if branch["id"] != "final_branch" and branch["status"] == "completed":
			completed += 1
	return completed


func _emit_progression_updated() -> void:
	progression_updated.emit()
