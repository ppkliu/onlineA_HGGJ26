# Break the Loop — 劇本設計總索引

> 本文件為 Break the Loop 劇本設計的**導航中心**。
> 所有劇本內容已拆分為三線架構（明線 / 暗線 / 真實線），分別存放在 `story/` 子目錄中。

---

## 三線敘事架構說明

Break the Loop 的劇本採用**三層敘事結構**，讓不同角色的團隊成員可以各取所需：

### 明線（Surface Line）— 給玩家看的

**一句話定義：** 玩家直接體驗到的故事。

讀完明線，就像讀完一本小說——不需要知道任何隱藏機制就能理解故事。明線的品質 = 敘事的戲劇張力。明線中不出現任何系統機制的說明（情報系統、解鎖條件等）。

**適合閱讀者：** 劇本寫作、美術（理解場景氛圍）、配音

### 暗線（Hidden Line）— 給設計師看的

**一句話定義：** 玩家主動調查才能發現的隱藏內容。

暗線定義了所有選擇肢、調查事件、情報觸發條件、NPC 的背景行為。暗線的品質 = 遊戲的探索深度與重玩價值。

**適合閱讀者：** 遊戲設計、程式（實作分支邏輯）、QA（測試路線覆蓋）

### 真實線（Canon Line）— 給作者看的

**一句話定義：** 故事的絕對真相，當明線和暗線產生矛盾時的最終裁判。

真實線包含完整的歷史年表、角色真實動機、不可變事件列表。遊戲中不會直接呈現真實線的內容——它是設計師確保一致性的工具。

**適合閱讀者：** 主設計師、劇本作者（確認設計一致性）

### 三線之間的關係

```
          ┌──────────────┐
          │   真實線      │  ← 最終裁判，所有設計以此為準
          │ Canon Line    │
          └──────┬───────┘
                 │ 驗證
        ┌────────┴────────┐
        │                 │
   ┌────┴────┐       ┌────┴────┐
   │  明線    │       │  暗線    │
   │ Surface  │       │ Hidden   │
   │ 玩家看到 │       │ 玩家發現 │
   └─────────┘       └─────────┘
```

---

## 文件導航

### 基礎設定

| 文件 | 內容 | 優先閱讀度 |
|---|---|---|
| [story/00_Timeline.md](story/00_Timeline.md) | **180 天主時間軸**（三線並列）。Canon Events、可改變節點、輪迴與時間的關係 | ★★★ 必讀 |
| [story/00_Characters.md](story/00_Characters.md) | **角色總表**。6 個核心角色的完整設定、勢力關係圖、每角色的 6 個月行為軌跡 | ★★★ 必讀 |

### 三線劇本

| 文件 | 內容 | 優先閱讀度 |
|---|---|---|
| [story/01_Surface_Line.md](story/01_Surface_Line.md) | **明線劇本**。序章 → 輪迴 1-5 的醒來/結局場景 → 最終輪迴完美路線 → 真結局。含情緒曲線與時間點標注 | ★★★ 必讀 |
| [story/02_Hidden_Line.md](story/02_Hidden_Line.md) | **暗線設計**。資訊溫室三層結構、所有調查事件（A-L）的完整腳本、情報系統、NPC 隱藏行為表、可探索物品 | ★★☆ 設計師必讀 |
| [story/03_Canon_Line.md](story/03_Canon_Line.md) | **真實線**。2 年完整歷史年表、角色真實動機深層分析、Canon Events 不可變列表、一致性驗證規則 | ★★☆ 主設計師必讀 |

### 技術框架

| 文件 | 內容 |
|---|---|
| [Break_the_Loop_Framework.md](Break_the_Loop_Framework.md) | 系統架構（Godot + Dialogic 2）、情報繼承系統、輪迴管理、音頻設計、場景轉場 |

---

## 建議閱讀順序

1. **先讀時間軸**（`00_Timeline.md`）— 建立 180 天的全局觀
2. **再讀角色表**（`00_Characters.md`）— 理解每個人的立場和動機
3. **然後讀明線**（`01_Surface_Line.md`）— 體驗完整的故事
4. **接著讀暗線**（`02_Hidden_Line.md`）— 理解遊戲機制如何支撐故事
5. **最後讀真實線**（`03_Canon_Line.md`）— 確認所有設計的一致性

---

## 附錄：Dialogic 時間線對照表

| 時間線檔案 | 對應內容 | 所在文件 | 預估字數 |
|---|---|---|---|
| `prologue/prologue_main.dtl` | 亡國之夜 | 明線：序章 | 300 字 |
| `prologue/prologue_assassination.dtl` | 騎士長的到來、刺殺 | 明線：序章 | 800 字 |
| `prologue/prologue_death.dtl` | 死亡情報畫面 | 明線：序章 | 150 字 |
| `loop_1/awakening.dtl` | 醒來、第一天的選擇 | 明線：輪迴 1 | 500 字 |
| `loop_1/investigation_a.dtl` | 調查階段 A + 溫室事件 | 暗線：第一~三章 | 2000 字 |
| `loop_1/branch_a_death.dtl` | 冒進、壞結局 A | 明線：壞結局 A | 1000 字 |
| `loop_2/awakening_with_intel.dtl` | 帶著痛覺醒來 | 明線：輪迴 2 | 400 字 |
| `loop_2/investigation_b.dtl` | 質問侍女、跟蹤騎士長、下城區 | 暗線：事件 H-J | 2000 字 |
| `loop_2/branch_b_death.dtl` | 壞結局 B | 明線：壞結局 B | 800 字 |
| `loop_3/awakening.dtl` ~ `loop_5/` | 中期輪迴全部 | 明線 + 暗線：事件 K-L | 2500 字 |
| `final_loop/awakening_final.dtl` | 最後一次醒來 | 明線：最終輪迴 | 300 字 |
| `final_loop/recruit_silas.dtl` | 收服騎士長 | 明線：最終輪迴 | 800 字 |
| `final_loop/calm_the_mob.dtl` | 安撫暴民 | 明線：最終輪迴 | 1000 字 |
| `final_loop/final_confrontation.dtl` | 揭露宰相 | 明線：最終輪迴 | 800 字 |
| `final_loop/true_ending.dtl` | 真結局 | 明線：真結局 | 600 字 |

**總估算劇本量：約 14,000 字（中文）**

---

## 內容遷移對照

> 原始的完整劇本已拆分至以下文件，此表供追蹤遷移完整性。

| 原始章節 | 目標文件 |
|---|---|
| 第一部分：角色總表與勢力關係 | `story/00_Characters.md` |
| 第二部分：序章劇本（2.1-2.4） | `story/01_Surface_Line.md` |
| 第三部分：資訊溫室設計 | `story/02_Hidden_Line.md` |
| 第四部分：第 1 輪迴 | 明線劇本 → `01_Surface_Line.md`，調查事件 → `02_Hidden_Line.md` |
| 第五部分：第 2 輪迴 | 明線劇本 → `01_Surface_Line.md`，調查事件 → `02_Hidden_Line.md` |
| 第六部分：中期輪迴 | 明線劇本 → `01_Surface_Line.md`，達爾證詞/宰相對質 → `02_Hidden_Line.md` |
| 第七部分：最終輪迴 | `story/01_Surface_Line.md` |
| 第八部分：情報總表 | `story/02_Hidden_Line.md` |
| 附錄：Dialogic 對照表 | 本文件（保留） |
| 180 天時間軸 | `story/00_Timeline.md`（全新撰寫） |
| 真實歷史、Canon Events | `story/03_Canon_Line.md`（全新撰寫） |

---

*本文件為劇本設計的總索引。具體內容請至各子文件查閱。*
*最後更新：2026-03-21*
