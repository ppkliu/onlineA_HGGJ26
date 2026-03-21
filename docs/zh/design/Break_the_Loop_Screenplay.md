# Break the Loop — 劇本設計總索引

> 本文件為 Break the Loop 劇本設計的**導航中心**。
> 劇本內容按**迴圈（Loop）分資料夾**存放，每個迴圈包含明線（surface.md）、暗線（hidden.md）、設計筆記（design_notes.md）。

---

## 核心架構：濾鏡反轉框架

Break the Loop 的敘事引擎是**四層濾鏡反轉**——每次輪迴的壞結局不是因為公主犯蠢，而是因為她帶著「合理但不完整的認知」做了看似正確的決策。

```
Loop 0（序章）     →  濾鏡 1：保護者變行刑者
Loop 1             →  濾鏡 2：慈父變暴君，好人變叛徒
Loop 2             →  濾鏡 3：可憐受害者變嗜血暴民
Loop 3（中期）     →  濾鏡 4：冷酷帝王變溫柔獻祭者
最終輪迴            →  所有濾鏡剝落 → 真結局
```

---

## 三線敘事說明

### 明線（Surface Line）— 給玩家看的

讀完明線，就像讀完一本小說——不需要知道任何隱藏機制就能理解故事。

**適合閱讀者：** 劇本寫作、美術（理解場景氛圍）、配音

### 暗線（Hidden Line）— 給設計師看的

暗線定義了所有選擇肢、調查事件、情報觸發條件、NPC 的背景行為。

**適合閱讀者：** 遊戲設計、程式（實作分支邏輯）、QA（測試路線覆蓋）

### 真實線（Canon Line）— 給作者看的

故事的絕對真相，當明線和暗線產生矛盾時的最終裁判。

**適合閱讀者：** 主設計師、劇本作者（確認設計一致性）

---

## 文件導航

### 共用參考文件

| 文件 | 內容 | 優先閱讀度 |
|---|---|---|
| [story/00_Reversal_Framework.md](story/00_Reversal_Framework.md) | **濾鏡反轉框架**。四層反轉的完整設計、公主內心獨白變化表、情報獲取流程圖 | ★★★ 必讀 |
| [story/00_Timeline.md](story/00_Timeline.md) | **180 天主時間軸**（三線並列）。Canon Events、可改變節點 | ★★★ 必讀 |
| [story/00_Characters.md](story/00_Characters.md) | **角色總表**。6 個核心角色的完整設定、勢力關係圖 | ★★★ 必讀 |
| [story/00_Canon_Line.md](story/00_Canon_Line.md) | **真實線**。完整歷史年表、角色動機、宰相偽證對照、Canon Events | ★★☆ 主設計師必讀 |

### 迴圈資料夾

| 資料夾 | 反轉 | 內容 |
|---|---|---|
| [story/loop_0_prologue/](story/loop_0_prologue/) | 反轉 1：保護者→行刑者 | 序章：亡國之夜，騎士長含淚刺殺公主 |
| [story/loop_1/](story/loop_1/) | 反轉 2：慈父→暴君 | **重寫**：公主被宰相操弄，交出兵符 → Bad End A |
| [story/loop_2/](story/loop_2/) | 反轉 3：受害者→暴民 | 公主直接救平民，被暴民出賣 → Bad End B |
| [story/loop_3_mid/](story/loop_3_mid/) | 反轉 4：帝王→獻祭者 | 公主獨自追查，發現地下防線但誤解父王 → Bad End C |
| [story/loop_final/](story/loop_final/) | 所有濾鏡剝落 | 收服騎士長 → 安撫暴民 → 揭露宰相 → 真結局 |

每個資料夾包含三個檔案：

| 檔案 | 內容 |
|---|---|
| `surface.md` | 明線劇本（對話腳本、場景描述、BGM/SFX 指示、內心獨白） |
| `hidden.md` | 暗線設計（調查事件、選擇肢、情報獲取、NPC 隱藏行為） |
| `design_notes.md` | 設計筆記（反轉要點、情緒目標、Dialogic 對照、前後版差異） |

### 技術框架

| 文件 | 內容 |
|---|---|
| [Break_the_Loop_Framework.md](Break_the_Loop_Framework.md) | 系統架構（Godot + Dialogic 2）、情報繼承系統、輪迴管理、音頻設計、場景轉場 |

---

## 建議閱讀順序

1. **先讀反轉框架**（`00_Reversal_Framework.md`）— 理解整個敘事引擎
2. **再讀時間軸**（`00_Timeline.md`）— 建立 180 天的全局觀
3. **然後讀角色表**（`00_Characters.md`）— 理解每個人的立場
4. **逐迴圈閱讀**：每個 `loop_X/` 先讀 `design_notes.md`（了解意圖）→ `surface.md`（讀劇本）→ `hidden.md`（看機制）
5. **最後讀真實線**（`00_Canon_Line.md`）— 確認所有設計的一致性

---

## 附錄：Dialogic 時間線對照表

| 時間線檔案 | 對應迴圈 | 內容 | 預估字數 |
|---|---|---|---|
| `prologue/prologue_main.dtl` | Loop 0 | 亡國之夜 | 300 字 |
| `prologue/prologue_assassination.dtl` | Loop 0 | 騎士長的到來、刺殺 | 800 字 |
| `prologue/prologue_death.dtl` | Loop 0 | 死亡情報畫面 | 150 字 |
| `loop_1/awakening.dtl` | Loop 1 | 醒來 | 300 字 |
| `loop_1/chancellor_visit.dtl` | Loop 1 | 宰相花園來訪 | 500 字 |
| `loop_1/evidence.dtl` | Loop 1 | 宰相展示偽證 | 400 字 |
| `loop_1/lower_district.dtl` | Loop 1 | 下城區見聞 | 300 字 |
| `loop_1/heist.dtl` | Loop 1 | 偷取兵符 | 300 字 |
| `loop_1/betrayal.dtl` | Loop 1 | 宰相撕下偽裝 | 600 字 |
| `loop_1/bad_end_a.dtl` | Loop 1 | Bad End A | 200 字 |
| `loop_2/awakening_angry.dtl` | Loop 2 | 帶著憤怒醒來 | 250 字 |
| `loop_2/infiltration.dtl` | Loop 2 | 潛入下城區 | 400 字 |
| `loop_2/daily_life.dtl` | Loop 2 | 下城區生活蒙太奇 | 300 字 |
| `loop_2/confession.dtl` | Loop 2 | 坦白身份 | 500 字 |
| `loop_2/mob_trial.dtl` | Loop 2 | 暴民審判 | 400 字 |
| `loop_2/bad_end_b.dtl` | Loop 2 | Bad End B | 300 字 |
| `loop_3/awakening_cold.dtl` | Loop 3 | 心死之後醒來 | 200 字 |
| `loop_3/search_dal.dtl` | Loop 3 | 尋找達爾 | 600 字 |
| `loop_3/underground.dtl` | Loop 3 | 發現地下防線 | 400 字 |
| `loop_3/misunderstanding.dtl` | Loop 3 | 錯誤的結論 | 400 字 |
| `loop_3/chancellor_strike.dtl` | Loop 3 | 宰相反撲 | 300 字 |
| `loop_3/bad_end_c.dtl` | Loop 3 | Bad End C | 300 字 |
| `final_loop/awakening_final.dtl` | Final | 最後一次醒來 | 300 字 |
| `final_loop/recruit_silas.dtl` | Final | 收服騎士長 | 600 字 |
| `final_loop/calm_mob.dtl` | Final | 安撫暴民 | 500 字 |
| `final_loop/expose_chancellor.dtl` | Final | 揭露宰相 | 600 字 |
| `final_loop/dawn.dtl` | Final | 真結局：破曉 | 500 字 |
| `final_loop/epilogue.dtl` | Final | 尾聲 | 100 字 |

**總估算劇本量：約 10,000 字（中文）**

---

*本文件為劇本設計的總索引。具體內容請至各子文件查閱。*
*最後更新：2026-03-21*
