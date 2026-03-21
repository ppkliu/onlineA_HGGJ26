extends Node

## 情報繼承系統 — 跨輪迴持久化的全域情報管理器
##
## 設計原則：
## - 情報一旦獲得，永不消失（即使輪迴重置）
## - 情報 ID 對應 Dialogic 條件分支
## - 支援存檔到磁碟（因為移除了 S/L，改用自動存檔）

signal intel_acquired(intel_id: String)
signal intel_journal_updated()

# 已獲得的情報集合 { intel_id: IntelItem }
var acquired_intels: Dictionary = {}

# 當前輪迴次數
var current_loop: int = 0

# 情報資料庫（從 Resource 載入）
var _intel_database: Dictionary = {}


func _ready() -> void:
	_load_intel_database()
	_load_persistent_data()


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
	_save_persistent_data()
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
	# 情報不重置！只重置場景相關狀態


## 持久化存檔（自動存檔，非手動 S/L）
func _save_persistent_data() -> void:
	var save_data = {
		"current_loop": current_loop,
		"acquired_intels": acquired_intels.keys(),
	}
	var file = FileAccess.open("user://break_the_loop_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))


## 讀取持久化資料
func _load_persistent_data() -> void:
	if not FileAccess.file_exists("user://break_the_loop_save.json"):
		return
	var file = FileAccess.open("user://break_the_loop_save.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if data:
			current_loop = data.get("current_loop", 0)
			for id in data.get("acquired_intels", []):
				if _intel_database.has(id):
					acquired_intels[id] = _intel_database[id]


## 將情報狀態同步到 Dialogic 變數（供 Dialogic 條件分支使用）
func sync_to_dialogic() -> void:
	if Engine.has_singleton("Dialogic") or ClassDB.class_exists(&"Dialogic"):
		for id in acquired_intels.keys():
			Dialogic.VAR.set(id, true)


## 完全重置（新遊戲）
func reset_all() -> void:
	acquired_intels.clear()
	current_loop = 0
	_save_persistent_data()
