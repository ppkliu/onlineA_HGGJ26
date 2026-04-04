# 美術資源驗證清單

> 根據 `.dch` 角色定義與 `art/characters/` 資料夾比對產生。
> 勾選代表已完成。

---

## 一、缺圖（角色進場必報錯）

**已全部以現有圖片暫代，遊戲不再報錯。** 正式美術完成後替換 `.dch` 內的路徑即可。

| 狀態 | 角色 | 來源檔 | 暫代圖 | 最終需補的圖 |
|---|---|---|---|---|
| [x] | 國王 | `king.dch` | `general_npc.png` | `king_default.png` |
| [x] | 達爾 | `dal.dch` | `suspect_a_default.png` | `dal_default.png` |
| [x] | 布魯諾 | `mob_leader.dch` | `suspect_b_default.png` | `mob_leader_default.png` |
| [x] | 暴民乙 | `mob_npc_b.dch` | `suspect_c_default.png` | `mob_npc_default.png` |
| [x] | 暴民丙 | `mob_npc_c.dch` | `suspect_c_default.png` | `mob_npc_default.png` |
| [x] | 老婦人 | `old_woman.dch` | `minister_npc.png` | `old_woman_default.png` |

---

## 二、表情佔位（所有表情指向同一張圖，無視覺差異）

### 宰相（`chancellor.dch`）

大綱需要：含笑迎客 → 語氣一轉 → 臉色微白（被召見時）。

| 狀態 | 表情名 | 現況 | 待補圖片 |
|---|---|---|---|
| [x] | `cold` | ✅ 已有獨立圖 `chancellor_cold.png` | — |
| [ ] | `concerned` | 佔位中，指向 `chancellor_default.png` | `chancellor_concerned.png` |
| [ ] | `determined` | 佔位中，指向 `chancellor_default.png` | `chancellor_determined.png` |
| [ ] | `relieved` | 佔位中，指向 `chancellor_default.png` | `chancellor_relieved.png` |
| [ ] | `sad` | 佔位中，指向 `chancellor_default.png` | `chancellor_sad.png` |
| [ ] | `serious` | 佔位中，指向 `chancellor_default.png` | `chancellor_serious.png` |

### 女僕（`maid.dch`）

大綱特別標記「眼眶微紅」為 A-V1 / A-V2 的敘事線索。

| 狀態 | 表情名 | 現況 | 待補圖片 |
|---|---|---|---|
| [x] | `tearful` | ✅ 已新增，暫用 `retainer_tearful.png` | `maid_tearful.png`（正式圖） |
| [ ] | `confused` | 佔位中，指向 `maid_portrait.png` | `maid_confused.png` |
| [ ] | `forced_smile` | 佔位中，指向 `maid_portrait.png` | `maid_forced_smile.png` |
| [ ] | `grateful` | 佔位中，指向 `maid_portrait.png` | `maid_grateful.png` |
| [ ] | `shocked` | 佔位中，指向 `maid_portrait.png` | `maid_shocked.png` |

### 賽拉斯（`loyal_retainer.dch`）

A-V1 場景需要「表情變了一瞬，立刻恢復」的防備感。

| 狀態 | 表情名 | 現況 | 待補圖片 |
|---|---|---|---|
| [x] | `guarded` | ✅ 已新增，暫用 `retainer_serious.png` | `retainer_guarded.png`（正式圖） |
| [ ] | `exhausted` | 佔位中，指向 `retainer_serious.png` | `retainer_exhausted.png` |
| [x] | `relieved` | 沿用 `retainer_tearful.png`（確認符合語意） | — |

### 布魯諾（`mob_leader.dch`）

所有表情暫用 `suspect_b_default.png`，正式圖到位後逐一替換。

| 狀態 | 表情名 | 待補圖片 |
|---|---|---|
| [ ] | `angry` | `mob_leader_angry.png` |
| [ ] | `suspicious` | `mob_leader_suspicious.png` |
| [ ] | `grieving` | `mob_leader_grieving.png` |
| [ ] | `hesitant` | `mob_leader_hesitant.png` |
| [ ] | `conflicted` | `mob_leader_conflicted.png` |
| [ ] | `broken` | `mob_leader_broken.png` |
| [ ] | `hopeful` | `mob_leader_hopeful.png` |
| [ ] | `shocked` | `mob_leader_shocked.png` |

---

## 三、資料夾中存在但未被任何 .dch 使用的圖片

| 狀態 | 圖片 | 處置建議 |
|---|---|---|
| [x] | `suspect_a_default.png/svg` | 已暫用為達爾的佔位圖 |
| [x] | `suspect_b_default.png/svg` | 已暫用為布魯諾的佔位圖 |
| [x] | `suspect_c_default.png/svg` | 已暫用為暴民乙/丙的佔位圖 |
| [x] | `general_npc.png` | 已暫用為國王的佔位圖 |
| [x] | `minister_npc.png` | 已暫用為老婦人的佔位圖 |
| [ ] | `retainer_default.png` | `loyal_retainer.dch` 的 default 已改指向 `knight_portrait.png`，確認是否刪除 |
| [ ] | `knight_npc.png/tres` | 無對應 .dch，確認是否為場景 overworld 用圖 |
| [ ] | `maid_npc.png/tres` | 同上 |

---

## 優先順序建議

1. ~~**先解決第一節（缺圖）**~~ ✅ 已完成（全部暫代）
2. **補女僕的正式各表情圖**：`tearful` 暫代圖視覺上會穿幫（用的是賽拉斯的圖），屬優先。
3. **補宰相/賽拉斯的各表情正式圖**：不影響執行，視美術進度補齊。
4. **確認 `retainer_default.png` 與 NPC `.tres` 用途**：整理時一併清理。
