# Break the Loop — 故事線總覽

> 參考來源：`docs/zh/design/story/` 各設計文件

---

## 世界觀與核心前提

王國面臨敵國入侵，宰相莫里昂暗中裡應外合，從內部破壞魔法防護陣、截留救濟糧、操弄暴民。公主艾蓮娜是城堡裡唯一「什麼都不知道」的人，也是唯一能打破輪迴的人。

---

## 設計架構：知識驅動分支樹

本遊戲採用**有向無環圖（DAG）**結構，而非線性迴圈。同一「情境」在不同知識狀態下，對白、選項、角色反應完全不同。

### 術語定義

| 術語 | 說明 |
|---|---|
| **情境（Scenario）** | 公主可選擇的行動路線，如「信任宰相」、「深入下城區」等 |
| **變體（Variant）** | 同一情境在特定知識狀態下的版本；每個變體有獨立對白與分支邏輯 |
| **知識狀態** | 公主目前持有的情報集合，決定可進入哪些變體、對白如何展開 |
| **鎖定（Locked）** | 該變體或情境不再可進入 |

### 無重複保證

系統在每次進入情境時記錄當下的知識狀態快照。若欲進入某情境時的知識狀態與先前某次進入完全相同，該情境自動封鎖——公主不會重蹈覆轍。

### 鎖定機制

- **主動鎖定**：公主持有特定情報，判斷此路線必死且已知結果，不會再走
- **耗盡鎖定**：情境下所有可達變體均已探索，且知識狀態不再改變
- **最終輪迴解鎖**：必須同時持有 `intel_chancellor_treason` ＋ `intel_assassination` ＋ `intel_king_defense_line`

---

## 序章（唯一執行一次）

**主要文件：** `00_prologue/`

固定事件，無分支。城破之夜，公主在寢房驚醒，賽拉斯依密令刺殺。序章結束後情報自動寫入，此情境永久鎖定。

**反轉：** 保護者 = 行刑者

**獲得情報：** `intel_city_fall` / `intel_assassination` / `intel_magic_core_sabotage`

---

## 情境 A：信任宰相

**主要文件：** `01_loop_1/`

**主動鎖定條件：** 持有 `intel_chancellor_poison`（公主知道毒茶在等她）

### 變體列表

| 變體 ID | 進入條件 | 公主視角 | 關鍵分歧點 | 結局 | 獲得情報 |
|---|---|---|---|---|---|
| A-V0 | 無相關情報 | 完全相信宰相的善意，是唯一對她好的人 | 主動交出城防令印 | Bad End A：毒茶刺殺 | `intel_chancellor_betrayal` |
| A-V1 | 持有 `intel_chancellor_betrayal`，未持有 `intel_fake_ledgers` / `intel_chancellor_poison` | 知道他是叛徒，假裝配合，暗中逐字核查帳簿細節 | 帳簿第七頁的刮改痕跡被記下；宰相察覺她過於平靜，提前下手 | Bad End A'：毒茶（宰相更謹慎，話更少） | `intel_fake_ledgers` |
| A-V2 | 持有 `intel_chancellor_betrayal` ＋ `intel_fake_ledgers`，未持有 `intel_chancellor_poison` | 掌握帳簿偽造的具體位置，決定正面攤牌 | 公主指出第七頁刮改；宰相首次摘下面具，以幽禁代替毒茶 | Bad End A''：被關押於東翼，死因不明 | `intel_chancellor_poison` → 觸發鎖定 |

> **變體遞進邏輯：** A-V0 → A-V1 → A-V2 → LOCK。A-V0 只讓公主知道「敵人是誰」，A-V1 讓她知道「偽造的具體方式」，A-V2 讓她認識「敵人有多少種手段」。持有 `intel_chancellor_poison` 後此情境主動鎖定。

> **注意：** A-V1 與 A-V2 的對白在帳簿場景、城防令印場景、以及死亡方式上完全不同。A-V2 是宰相唯一一次在公主面前摘下笑容的情境。

### 分支選項（各變體內）

- `03b_ask_king.dtl`（**僅 A-V0** 可觸發）：選擇先去問父王而非直接信任宰相
  - 進入條件：未持有 `intel_king_anger`
  - A-V1 / A-V2 公主目的明確，不走此分支

---

## 情境 B：深入下城區

**主要文件：** `02_loop_2/`

**耗盡鎖定條件：** 同時持有 `intel_mob_manipulation` ＋ `intel_starvation_real` ＋ `intel_bruno_wife_death`（公主已理解下城區所有結構，知道問題根源在上層而非底層）

### 變體列表

| 變體 ID | 進入條件 | 公主視角 | 關鍵分歧點 | 結局 | 獲得情報 |
|---|---|---|---|---|---|
| B-V0 | 無相關情報 | 天真建立信任，以為誠意能換到一切 | 布魯諾在壓力下出賣，未說出妻子的故事 | Bad End B：出賣給敵軍 | `intel_starvation_real` |
| B-V1 | 持有 `intel_starvation_real`，未持有 `intel_bruno_wife_death` | 知道饑荒是真的，攜帶物資先建立信任 | 物資贏得短暫好感，布魯諾在公主追問下說出妻子故事，但根本壓力仍超出物資能解決的範圍 | Bad End B'：布魯諾本人無法阻擋群體決定 | `intel_bruno_wife_death` |
| B-V2 | 持有 `intel_bruno_wife_death`，未持有 `intel_mob_manipulation` | 知道布魯諾最深的傷口，直接點名妻子之死 | 布魯諾被擊中，票數三比一仍輸——外部協調者的存在讓公主理解到群體被系統性操弄 | Bad End B''：布魯諾投反對票但被推翻，公主在移交時聽見「那個煽動者也找到了嗎」 | `intel_mob_manipulation` |
| B-V3 | 持有 `intel_bruno_wife_death` ＋ `intel_mob_manipulation` | 同時回應個人創傷與群體操弄，同步分化外部協調者 | 宰相的情報網比公主快——她進入下城區第幾天就已被發現；布魯諾把公主推出去自己留下 | Bad End B'''：公主逃脫，布魯諾被帶走 | — （觸發耗盡鎖定，情境關閉）|

> **變體遞進邏輯：** B-V0 → B-V1 → B-V2 → B-V3 → LOCK。每次失敗都讓公主更深地理解問題的結構——從「苦難是真的」到「傷口是個人的」到「操弄是系統性的」到「根源在上層」。

### 分支選項（各變體內）

- `03b_steal_supplies.dtl`（**僅 B-V0** 可觸發）：偷偷回城堡取食物藥品
  - 進入條件：未持有 `intel_chancellor_eyes`
  - B-V1 以上公主已帶補給或改變策略，此選項不出現
- `04b_rush_granary.dtl`（**B-V0 / B-V1 / B-V2** 坦白場景內可觸發）：立刻帶布魯諾去找地下糧倉
  - 進入條件：未持有 `intel_granary_needs_key`
  - 三個變體均以此鎖定「糧倉需要宰相鑰匙」這一知識點；一旦取得 `intel_granary_needs_key` 即自動消失

---

## 情境 C：獨自調查

**主要文件：** `03_loop_3/`

**耗盡鎖定條件：** 同時持有 `intel_chancellor_treason` ＋ `intel_king_defense_line`（公主已在塔樓拼出全貌，繼續獨自行動只會再次被幽禁）

### 變體列表

| 變體 ID | 進入條件 | 公主視角 | 關鍵分歧點 | 結局 | 獲得情報 |
|---|---|---|---|---|---|
| C-V0 | 無相關情報 | 不信任任何人，靠直覺摸索 | 找到達爾，但「唸詩聲音」無法與宰相連結；轉而接受「冷血帝王」邏輯 | Bad End C：幽禁，塔樓自盡 | `chancellor_treason` + `king_defense_line` + `dal_blinded_by_chancellor` |
| C-V1 | 持有 `intel_chancellor_betrayal`，未持有 `intel_dal_blinded_by_chancellor` | 明確鎖定宰相為目標，有意識地尋找反制證據 | 聽到達爾描述「唸詩聲音」立即連結宰相，但缺乏傳遞情報的渠道 | Bad End C'：幽禁，情報送出一半被截 | `intel_dal_blinded_by_chancellor` |
| C-V2 | 持有 `intel_king_defense_line`，未持有 `intel_chancellor_treason` | 知道防線被破壞，試圖從技術面修復 | 技術面幾乎能成功，但宰相從政治面介入，公主被誣陷叛國 | Bad End C''：被誣陷，幽禁（與 C-V0 不同牢房，對話不同） | `intel_chancellor_treason` |
| C-V3 | 持有 `intel_dal_blinded_by_chancellor` ＋ `intel_king_defense_line`，未持有 `intel_chancellor_treason` | 有人證有物證，試圖在被幽禁前傳遞給父王 | 宰相已在父王身邊佈局，傳遞路線全被封死 | Bad End C'''：人證被轉移，公主再次幽禁，但情報已部分外洩 | `intel_chancellor_treason` |

> C-V0 的達爾場景：公主聽到「唸詩」一頭霧水，繼續走冤枉路。C-V1 的達爾場景：公主聽到「唸詩」臉色驟變，台詞完全不同。C-V2 完全跳過達爾，直奔魔法陣，這是本情境中唯一不以達爾為核心的路線。

### 分支選項（各變體內）

- `02b_confront_chancellor.dtl`（C-V0 / C-V1 可觸發）：拿達爾證詞直接質問宰相
  - 進入條件：未持有 `intel_chancellor_dismisses_testimony`
- `03b_tell_king.dtl`（C-V0 / C-V1 / C-V3 可觸發）：立刻去告訴父王
  - 進入條件：未持有 `intel_king_will_listen`
- `04b_activate_alone.dtl`（C-V2 / C-V3 可觸發）：一個人試圖啟動防線
  - 進入條件：未持有 `intel_defense_needs_three`

---

## 最終輪迴

**主要文件：** `04_final_loop/`

**解鎖條件：** 同時持有 `intel_chancellor_treason` ＋ `intel_assassination` ＋ `intel_king_defense_line`

此情境只有一個主要版本，但各角色的對白深度因其他情報的持有狀況而異（例如：持有 `intel_bruno_wife_death` 時安撫布魯諾的說詞更直接；持有 `intel_mob_manipulation` 時對下城區的承諾更具體）。

**關鍵事件：**
1. 醒來，帶著完整真相，決心「換我來保護你了」
2. 收服賽拉斯：道出密令，讓他知道「你是唯一會為殺我而哭的人」
3. 安撫布魯諾：「我不是在施捨，是在歸還」
4. 朝堂揭露宰相：出示鐵證，讓他無路可退
5. 180 天後敵軍撤退，賽拉斯撕碎密令，破曉

**三步邏輯來源：**
| 步驟 | 來源情境 |
|---|---|
| 收服賽拉斯 | 序章：他是被逼殺我的，用理解贏得忠誠 |
| 安撫布魯諾 | 情境 B：暴民被操弄，用真相＋實際承諾 |
| 揭露宰相 | 情境 A ＋ 情境 C：掌握完整證據鏈，一次出示 |

**分支選項：**
- `03b_rush_arrest.dtl`：趁宰相不知情直接去抓（進入條件：未持有 `intel_chancellor_escape_plan`）

---

## 情報系統（跨情境繼承）

情報一旦取得，永久保留，影響後續所有情境的對白分支與變體解鎖。

| 情報 ID | 來源 | 主要效果 |
|---|---|---|
| `intel_city_fall` | 序章 | 後續違和感追問選項 |
| `intel_assassination` | 序章 | 賽拉斯特殊對話；最終輪迴解鎖條件之一 |
| `intel_magic_core_sabotage` | 序章 | 魔法陣情報基礎 |
| `intel_chancellor_betrayal` | A-V0 Bad End A | 確認宰相是叛徒；解鎖 A-V1、A-V2、C-V1 |
| `intel_fake_ledgers` | A-V1 Bad End A' | 帳簿偽造具體位置；解鎖 A-V2 |
| `intel_chancellor_poison` | A-V2 Bad End A'' | 宰相的消滅手段不只毒茶，因人而異；觸發情境 A 主動鎖定 |
| `intel_starvation_real` | B-V0 Bad End B | 下城區饑荒是真的；解鎖 B-V1 |
| `intel_bruno_wife_death` | B-V1 Bad End B' | 布魯諾妻子死因；解鎖 B-V2、B-V3 |
| `intel_mob_manipulation` | B-V2 Bad End B'' | 群體仇恨被系統性操弄；解鎖 B-V3；最終輪迴安撫場景加深 |
| `intel_chancellor_treason` | C-V0 / C-V2 / C-V3 | 宰相完整罪行；最終輪迴解鎖條件之一 |
| `intel_king_defense_line` | C-V0 / C-V1 | 地下防線真相；最終輪迴解鎖條件之一 |
| `intel_dal_blinded_by_chancellor` | C-V0 / C-V1 | 達爾被宰相弄瞎；解鎖 C-V3 |

---

## 公主角色弧線（知識積累視角）

| 階段 | 累積知識 | 核心偏見 | 被什麼打破 |
|---|---|---|---|
| 序章後 | `city_fall` / `assassination` / `magic_core_sabotage` | 無，但開始有違和感 | — |
| 情境 A 完整走完（V0→V1→V2）| `betrayal` → `fake_ledgers` → `poison` | 慈父 = 暴君 | 宰相的「真相」是精心篩選的謊言；他的手段因對象而異 |
| 情境 B 完整走完（V0→V1→V2→V3）| `starvation_real` → `bruno_wife_death` → `mob_manipulation` | 受害者 = 暴民 | 布魯諾不是壞人，是被系統逼到絕路的普通人 |
| 情境 C 完整走完 | `chancellor_treason` / `king_defense_line` / `dal_blinded_by_chancellor` | 父王是個怪物？ | 冷酷帝王 = 溫柔的獻祭者 |
| 最終輪迴 | 所有濾鏡剝落 | 無 | — |

---

## 角色速查

| 角色 | 定位 | 核心衝突 |
|---|---|---|
| 公主 艾蓮娜 | 玩家角色 | 唯一「什麼都不知道」的人 |
| 騎士長 賽拉斯 | 序章加害者 / 真最大受害者 | 持有殺死公主的密令，每天祈禱不需執行 |
| 宰相 莫里昂 | 幕後黑手 | 從不說謊，只省略真相 |
| 侍女 莉娜 | 善意的資訊牆 | 用笑容替公主擋住所有壞消息 |
| 工匠 達爾 | 破局的鑰匙 | 被宰相弄瞎，唯一能說明防線真相的人 |
| 鐵匠 布魯諾 | 被操弄的內應 | 妻子死於草藥被軍需徵用，被宰相利用 |
| 國王 | 缺席的父親 | 孤軍奮戰，用名聲換備戰時間 |

---

*參考文件：`docs/zh/design/story/` | 角色詳細設定：`00_Characters.md`*
