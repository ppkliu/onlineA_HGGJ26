# Break the Loop — 主框架開發 TodoList

> 開發引擎：Godot 4.6.1 ｜ 對話框架：Dialogic 2 ｜ 目標：Game Jam 可交付版本

---

## Phase 0：專案初始化

- [x] 建立 Godot 4.6.1 專案，設定專案名稱與基本參數
- [x] 設定解析度 1920×1080，Stretch Mode = `canvas_items`
- [x] 安裝 Dialogic 2 插件並啟用
- [x] 建立完整目錄結構（`autoload/`、`scenes/`、`resources/`、`art/`、`audio/`、`shaders/`、`dialogic/`）
- [x] 設定版本控制（`.gitignore` 加入 Godot 預設忽略項）
- [x] 建立 `project.godot` 中的 Autoload 註冊（GameManager、IntelSystem、LoopManager、AudioManager、SceneTransition）

---

## Phase 1：核心系統開發（優先級最高）

### 1.1 情報繼承變數系統（IntelSystem）

- [x] 建立 `intel_item.gd` Resource 腳本（id、title、description、category、source_loop、unlocks_branches）
- [x] 建立 `intel_database.tres` 情報資料庫，填入 8-12 條核心情報定義
- [x] 實作 `intel_system.gd` Autoload
  - [x] `acquire_intel()` — 獲得情報並發出信號
  - [x] `has_intel()` — 單一情報檢查
  - [x] `check_branch_condition()` — 多情報 AND 條件檢查
  - [x] `trigger_loop_reset()` — 輪迴重置（保留情報）
  - [x] `reset_all()` — 新遊戲完全重置
- [x] 實作自動存檔 / 讀檔（JSON 持久化到 `user://`）
- [x] 單元測試：確認情報跨輪迴保留、分支條件正確判定

### 1.2 輪迴管理器（LoopManager）

- [x] 實作 `loop_manager.gd` Autoload
  - [x] `trigger_death()` — 死亡觸發流程（獲得情報 → 死亡畫面 → 輪迴重置）
  - [x] `_reset_loop()` — 場景狀態清除 + 轉場到起點
  - [x] `_update_phase()` — 根據輪迴數 / 情報量判定當前階段
- [x] 定義 LoopPhase 枚舉（PROLOGUE / EARLY / MID / FINAL）
- [x] 實作 `scene_states` 字典管理（每輪迴內的一次性事件追蹤）

### 1.3 場景轉場控制（SceneTransition）

- [x] 建立 `scene_transition.tscn`（CanvasLayer + ColorRect + AnimationPlayer）
- [x] 製作轉場動畫
  - [x] `fade_out` / `fade_in` — 一般場景切換（黑色淡入淡出）
  - [x] `loop_restart_out` / `loop_restart_in` — 輪迴重啟（白光閃爍 → 漸入）
  - [x] `death_fade` / `death_reveal` — 死亡轉場（紅色褪入黑暗）
- [x] 實作 `transition_to()` 方法，支援三種 TransitionType

---

## Phase 2：Dialogic 2 整合

### 2.1 角色建立

- [x] 建立公主角色 `.dch`（含多表情立繪佔位：default、sad、angry、shocked、determined）
- [x] 建立忠臣角色 `.dch`
- [x] 建立嫌疑人 A `.dch`
- [x] 建立嫌疑人 B `.dch`
- [x] 建立嫌疑人 C `.dch`（選配，視時間決定）

### 2.2 對話樣式

- [x] 設定 `default_style.tres` — 一般對話框樣式（暗色系底框、白色文字）
- [x] 設定 `flashback_style.tres` — 回憶 / 死亡場景樣式（帶昏黃濾鏡的對話框）
- [ ] 調整字體（建議支援中文的 Noto Sans TC 或類似字體）

### 2.3 時間線撰寫

#### 序章

- [x] `prologue_main.dtl` — 王城陷落開場敘事
- [x] `prologue_assassination.dtl` — 忠臣刺殺場景（含 Cut to Silence 觸發）
- [x] `prologue_death.dtl` — 公主死亡 → 獲得第一條情報 → 輪迴啟動

#### 第 1 輪迴

- [x] `loop1/awakening.dtl` — 公主在寢宮醒來，帶著記憶的獨白
- [x] `loop1/investigation_a.dtl` — 調查場景 A（唯一可選路線）
- [x] `loop1/branch_a_death.dtl` — 壞結局 A → 獲得情報 ①

#### 第 2 輪迴

- [x] `loop2/awakening_with_intel.dtl` — 帶情報醒來，新的內心獨白
- [x] `loop2/branch_a_revisit.dtl` — 路線 A 重訪（因新情報出現新對話）
- [x] `loop2/branch_b_unlock.dtl` — 路線 B 解鎖後的新劇情
- [x] `loop2/branch_b_death.dtl` — 壞結局 B → 獲得情報 ②（選配）

#### 最終輪迴

- [x] `final/final_confrontation.dtl` — 揭露真相的最終對質
- [x] `final/true_ending.dtl` — 唯一真結局

### 2.4 Dialogic 與 IntelSystem 橋接

- [x] 實作 Dialogic 自訂事件 `DialogicIntelEvent`（在 timeline 中觸發情報獲取）
- [x] 實作 `_sync_to_dialogic()` — 將 IntelSystem 狀態同步到 Dialogic 變數
- [x] 在分歧選擇肢中加入 `[if IntelSystem.has_intel(...)]` 條件鎖定
- [ ] 測試：確認選擇肢根據情報狀態正確顯示 / 隱藏

---

## Phase 3：場景與 UI

### 3.1 遊戲場景

- [x] `main_menu.tscn` — 主選單（新遊戲 / 繼續 / 退出）
- [x] `game_scene.tscn` — 遊戲主場景容器（載入子場景 + Dialogic 對話層）
- [x] `royal_chamber.tscn` — 公主寢宮（輪迴起點）
- [x] `throne_room.tscn` — 王座大廳（序章 + 調查場景）
- [x] `castle_corridor.tscn` — 城堡走廊（場景間移動）（選配）
- [x] `garden.tscn` — 庭園（調查場景）（選配）

### 3.2 UI 介面

- [x] `intel_journal.tscn` — 情報日誌
  - [x] 分類頁籤切換（人物 / 陰謀 / 線索 / 真相）
  - [x] 情報卡片列表顯示
  - [x] 「NEW」標記動畫
  - [x] 快捷鍵綁定（`Tab` 或 `J`）
- [x] `death_screen.tscn` — 死亡情報獲得畫面
  - [x] 死因摘要文字顯示
  - [x] 情報卡片翻轉動畫
  - [x] 「帶著新的知識，回到過去……」提示文字
  - [x] 自動倒數 → 輪迴轉場
- [x] `loop_indicator.tscn` — 輪迴次數指示器（畫面角落）
- [x] `choice_panel.tscn` — 增強版選擇面板（鎖定選項灰色顯示 + 鎖頭圖示）

---

## Phase 4：美術資源

### 4.1 背景圖（最低需求）

- [ ] 序章 — 王城陷落（火海背景）
- [ ] 公主寢宮（輪迴起點場景）
- [ ] 王座大廳（調查場景）
- [ ] 庭園 或 城堡走廊（第二調查場景）（選配）

### 4.2 角色立繪

- [x] 公主 — 至少 3 個表情（default / sad / determined）
- [x] 忠臣 — 至少 2 個表情（default / tearful）
- [x] 嫌疑人 A — 至少 1 個表情
- [x] 嫌疑人 B — 至少 1 個表情

### 4.3 UI 素材

- [ ] 對話框底圖
- [ ] 情報卡片框架
- [ ] 選擇肢按鈕（正常 / 鎖定 / 懸停）
- [ ] 輪迴指示器圖形
- [ ] 鎖頭圖示（分支鎖定用）

### 4.4 效果素材

- [ ] 死亡轉場用紅色漸層遮罩
- [ ] 火焰粒子效果或靜態火焰疊圖（序章用）

---

## Phase 5：音效資源

- [x] `prologue_epic.ogg` — 序章史詩交響樂 BGM
- [x] `music_box_uneasy.ogg` — 輪迴重啟音樂盒旋律
- [x] `investigation.ogg` — 調查場景通用 BGM
- [x] `final_truth.ogg` — 最終真相揭露 BGM（選配）
- [x] `fire_burning.ogg` — 大火燃燒環境音效
- [x] `sword_stab.ogg` — 刺殺音效
- [x] `loop_restart.ogg` — 輪迴重啟過渡音效
- [x] `intel_acquired.ogg` — 獲得情報提示音
- [x] `corridor_crash.ogg` — 走廊重物倒地 / 拖行聲
- [x] `door_knock.ogg` — 敲門音效（基底版本）
- [x] `running_screams.ogg` — 遠處奔跑與尖叫（基底版本）
- [x] `armor_approach.ogg` — 盔甲腳步接近（基底版本）
- [x] `lock_break.ogg` — 門鎖破壞（基底版本）
- [x] `door_close.ogg` — 關門音效（基底版本）

### 5.1 已對齊的強化檔名別名

- [x] `door_knock_hard.ogg` — 由 `door_knock.ogg` 對齊供 Dialogic 使用
- [x] `running_screams_distant.ogg` — 由 `running_screams.ogg` 對齊供 Dialogic 使用
- [x] `armor_approach_heavy.ogg` — 由 `armor_approach.ogg` 對齊供 Dialogic 使用
- [x] `lock_break_forceful.ogg` — 由 `lock_break.ogg` 對齊供 Dialogic 使用
- [x] `door_close_slow.ogg` — 由 `door_close.ogg` 對齊供 Dialogic 使用
- [x] `sword_stab_short.ogg` — 由 `sword_stab.ogg` 對齊供 Dialogic 使用
- [x] `loop_restart_echo.ogg` — 由 `loop_restart.ogg` 對齊供 Dialogic 使用

### 5.2 目前仍缺的音效

### 5.2 目前仍缺的 BGM

- [x] `garden_afternoon.ogg` — 庭園 / 日間場景 BGM
- [x] `tension_low.ogg` — 低壓懸疑 BGM
- [x] `investigation_cold.ogg` — 冷調查場景 BGM
- [x] `underground.ogg` — 地下場景 BGM
- [x] `tension_stealth.ogg` — 潛行 / 偷行動段落 BGM
- [x] `tension_low_dark.ogg` — 更陰暗的低壓 BGM
- [x] `lower_district.ogg` — 下城區場景 BGM
- [x] `tension_rising.ogg` — 緊張升高 BGM

### 5.3 目前仍缺的 SFX

- [x] `distant_horn_three.ogg` — 遠方號角音效
- [x] `gate_open_heavy_three.ogg` — 沉重城門開啟音效（版本 three）
- [x] `gate_open_heavy.ogg` — 沉重城門開啟音效

---

## Phase 6：Shader 效果

- [x] `vignette.gdshader` — 暗角效果（調查場景常駐）
- [x] `sepia_flashback.gdshader` — 昏黃回憶色調濾鏡
- [x] `death_fade.gdshader` — 死亡紅色褪入黑暗效果

---

## Phase 7：整合測試

- [ ] 完整流程測試：序章 → 第 1 輪迴 → 壞結局 → 第 2 輪迴 → 新分支解鎖
- [x] 情報系統測試：確認所有情報正確獲取、持久化、跨輪迴保留
- [x] 分支解鎖測試：確認條件判定正確，鎖定選項無法點擊
- [ ] 音效流程測試：序章音樂 → Cut to Silence → 音樂盒旋律 的切換順暢
- [ ] 轉場測試：三種轉場動畫正確播放、無卡頓
- [ ] 自動存檔測試：中途關閉遊戲 → 重開後正確恢復輪迴進度與情報
- [ ] 新遊戲測試：確認 `reset_all()` 完全清除所有狀態
- [ ] 死亡畫面測試：確認情報卡片動畫正確、自動轉場正常
- [ ] 真結局路線測試：收集所有情報後，最終輪迴正確觸發
- [ ] 中文字體顯示測試：確認所有 UI 與 Dialogic 對話框中文正常顯示

---

## Phase 8：打磨與提交

- [ ] 遊戲開頭加入遊戲名稱標題畫面
- [ ] 調整對話節奏與文字速度
- [ ] 調整音量平衡（BGM / SFX / Ambience）
- [x] 加入簡易操作提示（首次遊玩引導）
- [ ] 匯出可執行檔（Windows / macOS / Web）
- [ ] 撰寫 Game Jam 提交說明（遊戲簡介 + 操作說明 + 開發工具列表）
- [ ] 最終完整遊玩測試（從頭到真結局至少通關一次）

---

## 情報設計速查表（規劃用）

| 情報 ID | 名稱 | 獲得方式 | 解鎖分支 |
|---|---|---|---|
| `intel_city_fall` | 城破的結果 | 序章自動獲得 | — |
| `intel_retainer_motive` | 忠臣的理由 | 壞結局 A | branch_b |
| `intel_faction_a` | 勢力 A 的線索 | 調查場景 A 對話 | branch_c |
| `intel_faction_b` | 勢力 B 的線索 | 調查場景 B 對話 | branch_d |
| `intel_conspiracy_evidence` | 陰謀的證據 | 壞結局 B | branch_confrontation |
| `intel_dungeon_key` | 地下牢的秘密 | 中期輪迴特定對話 | branch_dungeon |
| `intel_retainer_past` | 忠臣的過去 | 質問忠臣（需多條前置情報） | branch_truth |
| `intel_true_traitor` | 真正的內鬼 | 地下牢調查 | final_branch |

> 以上為規劃範例，實際情報內容需配合完整劇本填入。

---

## 優先級排序建議

```
🔴 必做（Game Jam 最低可交付）
  Phase 0 全部
  Phase 1 全部
  Phase 2.1 公主 + 忠臣角色
  Phase 2.2 default_style
  Phase 2.3 序章 + 第 1 輪迴
  Phase 2.4 橋接功能
  Phase 3.1 main_menu + game_scene + royal_chamber + throne_room
  Phase 3.2 death_screen + choice_panel
  Phase 5 至少 3 條音效（prologue_epic、sword_stab、music_box_uneasy）

🟡 應做（完整體驗）
  Phase 2.3 第 2 輪迴 + 最終輪迴
  Phase 3.2 intel_journal + loop_indicator
  Phase 4 全部最低需求
  Phase 5 全部
  Phase 7 全部

🟢 加分（時間允許）
  Phase 2.1 嫌疑人 C
  Phase 4 選配場景
  Phase 6 Shader 效果
  Phase 8 打磨
```

---

*最後更新：2026-03-22*
