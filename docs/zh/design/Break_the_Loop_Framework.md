# Break the Loop — Godot 4.6.1 遊戲主框架設計說明書

> 「完美公主的無知，造就了亡國的迴圈。唯有直面殘酷的真相，才能真正的 Break the Loop。」

---

## 1. 專案概述

| 項目 | 說明 |
|---|---|
| 遊戲名稱 | Break the Loop |
| 類型 | 懸疑文字冒險 × 解謎推理 × 情報繼承 |
| 引擎 | Godot 4.6.1 |
| 對話框架 | Dialogic 2（Visual Novel 模式） |
| 目標平台 | PC（Windows / macOS / Linux） |
| 開發規模 | Game Jam 精準實作範圍 |

### 1.1 核心概念

玩家扮演一位天真無知的亡國公主。在被最信任的忠臣含淚刺殺後，公主帶著完整記憶回到半年前。透過反覆的死亡輪迴，收集情報、拼湊真相，最終找出內鬼，打破國家覆滅的死亡迴圈。

### 1.2 設計哲學

- **以悲劇為主體**：死亡不是懲罰，而是推進故事的唯一鑰匙
- **情報即力量**：每一次輪迴，公主（與玩家）都變得更強大
- **唯一真結局**：完美的結局需要完整的理解與同理
- **完全移除 S/L**：壞結局 = 獲得情報、解鎖新路線

---

## 2. 專案目錄結構

```
break_the_loop/
├── project.godot
├── addons/
│   └── dialogic/                    # Dialogic 2 插件
│
├── autoload/
│   ├── game_manager.gd              # 遊戲全局管理器
│   ├── intel_system.gd              # 情報繼承變數系統（核心）
│   ├── loop_manager.gd              # 輪迴狀態管理
│   ├── audio_manager.gd             # 音效 / BGM 管理
│   └── scene_transition.gd          # 場景轉場控制
│
├── dialogic/
│   ├── timelines/                   # Dialogic 時間線（劇情腳本）
│   │   ├── prologue/                # 序章：王城陷落
│   │   │   ├── prologue_main.dtl
│   │   │   ├── prologue_assassination.dtl
│   │   │   └── prologue_death.dtl
│   │   ├── loop_1/                  # 第 1 輪迴
│   │   │   ├── awakening.dtl
│   │   │   ├── investigation_a.dtl
│   │   │   └── branch_a_death.dtl
│   │   ├── loop_2/                  # 第 2 輪迴
│   │   │   ├── awakening_with_intel.dtl
│   │   │   ├── investigation_b.dtl
│   │   │   ├── branch_a_revisit.dtl
│   │   │   └── branch_b_unlock.dtl
│   │   └── final_loop/              # 最終輪迴
│   │       ├── final_confrontation.dtl
│   │       └── true_ending.dtl
│   │
│   ├── characters/                  # Dialogic 角色定義
│   │   ├── princess.dch
│   │   ├── loyal_retainer.dch       # 忠臣
│   │   ├── suspect_a.dch
│   │   ├── suspect_b.dch
│   │   └── suspect_c.dch
│   │
│   └── styles/                      # Dialogic 對話框樣式
│       ├── default_style.tres
│       └── flashback_style.tres     # 回憶 / 死亡場景樣式
│
├── scenes/
│   ├── main_menu/
│   │   ├── main_menu.tscn
│   │   └── main_menu.gd
│   ├── game/
│   │   ├── game_scene.tscn          # 遊戲主場景容器
│   │   └── game_scene.gd
│   ├── locations/                   # 場景地點（RPG 探索用）
│   │   ├── royal_chamber.tscn       # 公主寢宮
│   │   ├── throne_room.tscn         # 王座大廳
│   │   ├── castle_corridor.tscn     # 城堡走廊
│   │   ├── garden.tscn              # 庭園
│   │   └── dungeon.tscn             # 地下牢
│   ├── ui/
│   │   ├── intel_journal.tscn       # 情報日誌 UI
│   │   ├── intel_journal.gd
│   │   ├── choice_panel.tscn        # 選擇面板（增強版）
│   │   ├── loop_indicator.tscn      # 輪迴次數指示器
│   │   └── death_screen.tscn        # 死亡 → 情報獲得畫面
│   └── transitions/
│       ├── loop_restart.tscn        # 輪迴重啟轉場
│       └── death_transition.tscn    # 死亡轉場
│
├── resources/
│   ├── intel_data/                  # 情報資料定義
│   │   ├── intel_database.tres      # 所有情報的資料庫
│   │   └── intel_item.gd            # 單一情報 Resource 腳本
│   ├── branch_data/                 # 分支解鎖條件定義
│   │   └── branch_conditions.tres
│   └── loop_data/                   # 輪迴階段資料
│       └── loop_progression.tres
│
├── art/
│   ├── backgrounds/                 # 場景背景圖（中世紀手繪風格）
│   ├── characters/                  # 角色立繪
│   ├── ui/                          # UI 素材
│   └── effects/                     # 特效素材（火焰、血跡等）
│
├── audio/
│   ├── bgm/
│   │   ├── prologue_epic.ogg        # 序章：史詩交響樂
│   │   ├── music_box_uneasy.ogg     # 輪迴：音樂盒旋律
│   │   ├── investigation.ogg        # 調查場景 BGM
│   │   └── final_truth.ogg          # 最終真相
│   └── sfx/
│       ├── fire_burning.ogg         # 大火燃燒
│       ├── sword_stab.ogg           # 刺殺音效
│       ├── silence_cut.ogg          # 靜音切入（空白音檔標記用）
│       ├── loop_restart.ogg         # 輪迴重啟音效
│       └── intel_acquired.ogg       # 獲得情報
│
└── shaders/
    ├── vignette.gdshader            # 暗角效果
    ├── sepia_flashback.gdshader     # 昏黃回憶濾鏡
    └── death_fade.gdshader          # 死亡褪色效果
```

---

## 3. 核心系統架構

### 3.1 情報繼承變數系統（Intel System）— 最核心

此系統是整個遊戲的技術核心。利用全域變數（Global Variables）儲存每輪迴獲得的情報，使分歧點根據情報狀態動態解鎖對話選項。死亡觸發輪迴重置，但保留情報變數。

```
autoload/intel_system.gd
```

```gdscript
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


## 完全重置（新遊戲）
func reset_all() -> void:
	acquired_intels.clear()
	current_loop = 0
	_save_persistent_data()
```

#### 3.1.1 情報資料 Resource

```gdscript
# resources/intel_data/intel_item.gd
extends Resource
class_name IntelItem

@export var id: String = ""                          # 唯一識別碼，如 "intel_retainer_motive"
@export var title: String = ""                       # 顯示名稱
@export var description: String = ""                 # 情報內容描述
@export var category: StringName = &"general"        # 分類：general / character / conspiracy / truth
@export var source_loop: int = -1                    # 在第幾輪迴可首次獲得（設計用）
@export var icon: Texture2D = null                   # 情報圖示
@export var unlocks_branches: Array[String] = []     # 此情報解鎖的分支 ID
```

### 3.2 輪迴管理器（Loop Manager）

```gdscript
# autoload/loop_manager.gd
extends Node

## 輪迴管理器 — 控制死亡、重生、場景重置的完整流程

signal loop_started(loop_number: int)
signal death_triggered(death_context: Dictionary)
signal loop_phase_changed(phase: StringName)

enum LoopPhase {
	PROLOGUE,       # 第 0 輪迴（序章）
	EARLY,          # 第 1-2 輪迴（摸索期）
	MID,            # 中期輪迴（推理期）
	FINAL,          # 最終輪迴
}

var current_phase: LoopPhase = LoopPhase.PROLOGUE
# 當前輪迴中的場景進度狀態（每次輪迴重置）
var scene_states: Dictionary = {}


func _ready() -> void:
	_update_phase()


## 觸發死亡 → 進入死亡畫面 → 獲得情報 → 輪迴重啟
func trigger_death(context: Dictionary = {}) -> void:
	# context 範例：{ "killer": "retainer", "intel_reward": "intel_001", "scene": "throne_room" }

	death_triggered.emit(context)

	# 1. 獲得此次死亡帶來的情報
	if context.has("intel_reward"):
		var rewards: Array = []
		if context["intel_reward"] is Array:
			rewards = context["intel_reward"]
		else:
			rewards = [context["intel_reward"]]
		for reward in rewards:
			IntelSystem.acquire_intel(reward)

	# 2. 顯示死亡畫面 + 情報獲得動畫（由 UI 層處理）
	await _show_death_screen(context)

	# 3. 執行輪迴重置
	_reset_loop()


## 輪迴重置
func _reset_loop() -> void:
	IntelSystem.trigger_loop_reset()
	scene_states.clear()
	_update_phase()
	loop_started.emit(IntelSystem.current_loop)

	# 轉場到公主寢宮（輪迴起點）
	SceneTransition.transition_to("res://scenes/locations/royal_chamber.tscn",
		SceneTransition.TransitionType.LOOP_RESTART)


## 根據輪迴次數與情報量更新階段
func _update_phase() -> void:
	var loop = IntelSystem.current_loop
	var intel_count = IntelSystem.acquired_intels.size()

	var old_phase = current_phase
	if loop == 0:
		current_phase = LoopPhase.PROLOGUE
	elif loop <= 2:
		current_phase = LoopPhase.EARLY
	elif intel_count >= _get_final_threshold():
		current_phase = LoopPhase.FINAL
	else:
		current_phase = LoopPhase.MID

	if current_phase != old_phase:
		loop_phase_changed.emit(StringName(LoopPhase.keys()[current_phase]))


func _get_final_threshold() -> int:
	# 需要收集到的情報數量才能進入最終輪迴
	return 8  # 根據實際情報數量調整


func _show_death_screen(context: Dictionary) -> void:
	var death_screen = load("res://scenes/ui/death_screen.tscn").instantiate()
	get_tree().root.add_child(death_screen)
	death_screen.setup(context)
	await death_screen.animation_completed
	death_screen.queue_free()
```

### 3.3 Dialogic 2 整合層

#### 3.3.1 自訂 Dialogic 事件 — 情報獲取

為了在 Dialogic 時間線中直接觸發情報獲取，需要建立自訂事件：

```gdscript
# addons/dialogic/custom_events/intel_event.gd
extends DialogicEvent
class_name DialogicIntelEvent

var intel_id: String = ""

func _execute() -> void:
	IntelSystem.acquire_intel(intel_id)
	finish()
```

#### 3.3.2 Dialogic 條件分支與情報連動

在 Dialogic 2 時間線（`.dtl`）中使用 GDScript 條件來檢查情報狀態：

```
# 範例 timeline: loop_2/awakening_with_intel.dtl

princess: （我……又回到了這裡。）
princess: （但這一次，我知道了一些事情。）

if IntelSystem.has_intel("intel_retainer_motive"):
    princess: （忠臣……他說的理由，真的是為了保護我嗎？）
    jump investigation_b_deep
else:
    princess: （我需要去找更多的線索。）
    jump investigation_b_surface
```

#### 3.3.3 選擇肢動態鎖定/解鎖

```
# 範例：分歧點 A 的選擇肢

- 前往王座大廳調查
- 潛入地下牢 [if IntelSystem.has_intel("intel_dungeon_key")]
- 質問忠臣 [if IntelSystem.check_branch_condition(["intel_retainer_motive", "intel_conspiracy_evidence"])]
```

### 3.4 音效管理器（Audio Manager）

針對本遊戲「靜默比音樂更震撼」的設計哲學，音效系統需要特別處理「Cut to Silence」效果。

```gdscript
# autoload/audio_manager.gd
extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer

var _bgm_tween: Tween


## 三段式音樂設計對應方法

## 序章：史詩交響樂 + 大火音效
func play_prologue_epic() -> void:
	_crossfade_bgm(preload("res://audio/bgm/prologue_epic.ogg"))
	ambience_player.stream = preload("res://audio/sfx/fire_burning.ogg")
	ambience_player.play()


## 核心效果：Cut to Silence（瞬間靜音）
## 用於忠臣刺殺瞬間 — 所有聲音瞬間消失
func cut_to_silence() -> void:
	if _bgm_tween:
		_bgm_tween.kill()
	bgm_player.stop()
	ambience_player.stop()
	sfx_player.stop()
	# 短暫延遲後播放刺殺音效（極低音量、極短）
	await get_tree().create_timer(0.8).timeout
	sfx_player.stream = preload("res://audio/sfx/sword_stab.ogg")
	sfx_player.volume_db = -10.0
	sfx_player.play()


## 輪迴重啟：音樂盒旋律
func play_loop_restart() -> void:
	await get_tree().create_timer(1.5).timeout  # 保持靜默片刻
	_crossfade_bgm(preload("res://audio/bgm/music_box_uneasy.ogg"), 3.0)


func _crossfade_bgm(stream: AudioStream, duration: float = 1.0) -> void:
	if _bgm_tween:
		_bgm_tween.kill()
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(bgm_player, "volume_db", -40.0, duration * 0.5)
	await _bgm_tween.finished
	bgm_player.stream = stream
	bgm_player.play()
	_bgm_tween = create_tween()
	_bgm_tween.tween_property(bgm_player, "volume_db", 0.0, duration * 0.5)
```

### 3.5 場景轉場控制

```gdscript
# autoload/scene_transition.gd
extends CanvasLayer

enum TransitionType {
	FADE_BLACK,         # 一般場景切換
	LOOP_RESTART,       # 輪迴重啟（特殊動畫）
	DEATH,              # 死亡轉場
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

signal transition_midpoint  # 轉場中點（可在此切換場景）


func transition_to(scene_path: String, type: TransitionType = TransitionType.FADE_BLACK) -> void:
	match type:
		TransitionType.FADE_BLACK:
			animation_player.play("fade_out")
		TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_out")
		TransitionType.DEATH:
			animation_player.play("death_fade")

	await animation_player.animation_finished
	transition_midpoint.emit()

	get_tree().change_scene_to_file(scene_path)

	match type:
		TransitionType.FADE_BLACK:
			animation_player.play("fade_in")
		TransitionType.LOOP_RESTART:
			animation_player.play("loop_restart_in")
		TransitionType.DEATH:
			animation_player.play("death_reveal")

	await animation_player.animation_finished
```

---

## 4. 遊戲流程架構

### 4.1 整體流程

```
主選單
  │
  ├─ 新遊戲 → 完全重置情報 → 序章
  └─ 繼續遊戲 → 讀取自動存檔 → 當前輪迴起點
         │
         ▼
    ┌─────────────────────────────────────┐
    │  序章（第 0 輪迴）：王城陷落          │
    │  ・王城陷入火海                       │
    │  ・忠臣含淚刺殺公主                   │
    │  ・Cut to Silence                    │
    │  ・公主死亡 → 獲得情報：城破的結果     │
    └──────────────┬──────────────────────┘
                   ▼
    ┌─────────────────────────────────────┐
    │  輪迴起點：公主寢宮醒來               │
    │  ・時間：戰爭爆發的半年前              │
    │  ・記憶完整保留                       │
    │  ・情報日誌可查閱已知線索              │
    └──────────────┬──────────────────────┘
                   ▼
    ┌─────────────────────────────────────┐
    │  調查階段                            │
    │  ・RPG 式城堡探索（點擊場景移動）      │
    │  ・與 NPC 對話（Dialogic 時間線）      │
    │  ・選擇肢根據情報動態解鎖              │
    └──────┬──────────────────┬───────────┘
           ▼                  ▼
     ┌───────────┐    ┌──────────────┐
     │ 壞結局 A   │    │  壞結局 B     │    ← 每個壞結局都是一塊拼圖
     │ → 情報 ①  │    │  → 情報 ②    │
     └─────┬─────┘    └──────┬───────┘
           │                  │
           └────────┬─────────┘
                    ▼
            回到輪迴起點（帶著新情報）
                    │
                    ▼  （重複直到收集足夠情報）
    ┌─────────────────────────────────────┐
    │  最終輪迴                            │
    │  ・所有分支解鎖                       │
    │  ・完美決策路線開放                    │
    │  ・唯一真結局                         │
    └─────────────────────────────────────┘
```

### 4.2 輪迴階段對照表

| 階段 | 輪迴 | 玩家狀態 | 公主狀態 | 獲得情報 |
|---|---|---|---|---|
| 第 0 輪迴（序章） | 0 | 震驚、困惑 | 無知、被殺 | 城破的結果 |
| 第 1-2 輪迴 | 1-2 | 摸索、試錯 | 開始懷疑 | 各方勢力線索 |
| 中期輪迴 | 3-5 | 推理、拼湊 | 逐漸覺醒 | 內鬼的動機 |
| 最終輪迴 | 6+ | 確信、決斷 | 完全覺醒 | 完整真相 |

### 4.3 折返跑機制詳解

```
第 1 輪迴
└─ 分歧點 A（無知狀態）
   ├─ A 路線（唯一可選）→ 死亡結局 → 獲得情報 ①
   └─ B 路線（鎖定 🔒）

第 2 輪迴（帶著情報 ① 重生）
└─ 分歧點 A（情報解鎖）
   ├─ A 路線 → 新的死亡 → 獲得情報 ②
   └─ B 路線（解鎖 🔓）→ 推進故事 → 新分歧點 B

最終輪迴
└─ 拼湊所有情報 → 完美決策 → 唯一真結局 🏆
```

---

## 5. Dialogic 2 設定指南

### 5.1 插件安裝與設定

1. 從 Godot Asset Library 或 GitHub 安裝 Dialogic 2
2. 在 `Project > Project Settings > Plugins` 中啟用 Dialogic
3. 設定 Dialogic 為 Visual Novel 模式

### 5.2 角色設定規範

每個角色 `.dch` 檔案需包含：

| 欄位 | 說明 | 範例 |
|---|---|---|
| Display Name | 對話框顯示名稱 | 艾蓮娜（公主） |
| Color | 角色代表色 | #FFD700（金色） |
| Portraits | 立繪表情組 | default, sad, angry, shocked, determined |
| Description | 角色背景（開發用） | 王國嫡系公主，天真善良 |

### 5.3 時間線命名規範

```
{輪迴階段}_{場景}_{事件}.dtl

範例：
prologue_throne_assassination.dtl
loop1_chamber_awakening.dtl
loop2_garden_suspect_a_talk.dtl
final_throne_confrontation.dtl
```

### 5.4 變數與 Dialogic 的橋接

在 Dialogic 2 中使用外部 GDScript 變數：

```
# 在 timeline 中使用條件
if {IntelSystem.has_intel("intel_001")}:
    ...

# 或使用 Dialogic 內建變數同步
# 在 intel_system.gd 中同步到 Dialogic：
func _sync_to_dialogic() -> void:
    for id in acquired_intels.keys():
        Dialogic.VAR.set(id, true)
```

---

## 6. UI 系統設計

### 6.1 情報日誌（Intel Journal）

玩家可隨時開啟的情報收集日誌，按分類顯示已獲得的情報。

功能需求：
- 分類頁籤：人物、陰謀、線索、真相
- 新獲得的情報帶有「NEW」標記
- 情報之間可顯示關聯線（選配）
- 快捷鍵 `Tab` 或 `J` 開啟

### 6.2 死亡畫面

死亡後不是 Game Over 畫面，而是「情報獲得」畫面：
- 畫面先暗下，顯示死因摘要
- 接著以動畫展示新獲得的情報卡片
- 底部顯示「帶著新的知識，回到過去……」
- 自動轉場到輪迴起點

### 6.3 輪迴指示器

畫面角落的小型 UI，顯示當前輪迴次數（例如以逐漸堆疊的圓環或沙漏表示）。

---

## 7. 視覺與音效規格

### 7.1 畫面風格

| 項目 | 規格 |
|---|---|
| 參考風格 | Rusty Lake 系列的點擊調查感 |
| 探索模式 | RPG 形式的城堡內部探索 |
| 插圖風格 | 中世紀手繪風格，帶有昏黃燭光氛圍 |
| 解析度 | 1920 × 1080（16:9） |
| 色調 | 暗色基底，紅色作為警示 / 強調色 |

### 7.2 音樂設計（三段式對比）

| 場景 | 音樂 | 情緒 |
|---|---|---|
| 序章：王城陷落 | 史詩交響樂 + 大火燃燒音效 | 震撼、絕望 |
| 忠臣刺殺瞬間 | **Cut to Silence**（瞬間靜音） | 窒息、背叛感 |
| 輪迴重啟 | 輕柔卻帶不安感的音樂盒旋律 | 虛假的日常、不安 |

> 「靜默」本身就是最強烈的音效。當所有聲音在刺殺瞬間消失，玩家會感受到比任何音樂都更深刻的衝擊。

### 7.3 Shader 效果

| Shader | 用途 | 時機 |
|---|---|---|
| vignette | 暗角壓迫感 | 調查場景常駐 |
| sepia_flashback | 昏黃回憶色調 | 回憶片段 / 序章重播 |
| death_fade | 紅色褪入黑暗 | 死亡轉場 |

---

## 8. Autoload 註冊表

在 `project.godot` 中需要註冊的 Autoload：

| 名稱 | 路徑 | 說明 |
|---|---|---|
| GameManager | `res://autoload/game_manager.gd` | 遊戲全局管理 |
| IntelSystem | `res://autoload/intel_system.gd` | 情報繼承系統 |
| LoopManager | `res://autoload/loop_manager.gd` | 輪迴管理 |
| AudioManager | `res://autoload/audio_manager.gd` | 音效管理 |
| SceneTransition | `res://autoload/scene_transition.gd` | 場景轉場 |

---

## 9. Game Jam 實作範圍界定

| 項目 | 範圍 |
|---|---|
| 完整輪迴分支數 | 1 至 2 個完整分支 |
| 核心體驗驗證 | 收集情報 → 死亡 → 重生解鎖新選項 |
| 美術資源 | 序章場景 + 至少 2 個調查場景 |
| 音效設計 | 序章音樂 + 靜音效果 + 音樂盒主旋律 |
| 角色數量 | 公主 + 忠臣 + 2-3 名嫌疑人 |
| 情報數量 | 8-12 條核心情報 |
| 結局數量 | 3-4 個壞結局 + 1 個真結局 |

---

## 10. 設計原則總結

1. **死亡即進度** — 每一次死亡都是新的線索，玩家永遠不會「浪費時間」
2. **分支皆有遺憾** — 除唯一真結局外，所有分支都帶有缺憾，推動玩家繼續探索
3. **拼湊真相** — 玩家需理解所有勢力的苦衷，才能達成完美結局
4. **情緒設計** — 讓玩家在每一次死亡後感受到「原來如此」的頓悟感，而非挫敗感
5. **無知的代價** — 這不只是一個「找出內鬼」的故事，而是關於「無知的代價」與「理解的力量」

---

*本文件基於 Godot 4.6.1 + Dialogic 2 Visual Novel 框架撰寫。*
*最後更新：2026-03-21*
