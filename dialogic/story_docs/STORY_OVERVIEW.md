# Break the Loop — 故事線總覽

> 本文件為故事設計的快速索引。詳細場景大綱見各 `scenario_*_outline.md`；回圈結構與情報表的權威來源為 `LOOP_OUTLINE.md`。

---

## 世界觀與核心前提

王國面臨敵國入侵，宰相莫里昂暗中裡應外合，從內部破壞魔法防護陣、截留救濟糧、操弄暴民。公主艾蓮娜是城堡裡唯一「什麼都不知道」的人，也是唯一能打破輪迴的人。

---

## 設計架構：線性主線 + 知識狀態驅動的變體

本遊戲為**線性敘事主線**：序章 → LOOP 1（A 線）→ LOOP 2（B 線）→ LOOP 3（C 線，C-2 含「破局的抉擇」）→ 終章 D（LOOP 4）。中途分歧**不改變**後續主要劇情，僅影響**台詞色彩與開場獨白**。

### 核心機制

| 機制 | 說明 |
|---|---|
| **輪迴重置** | 每輪開始世界狀態完全重置；NPC 不記得上輪 |
| **公主記憶** | 公主保留所有回圈的記憶——這是她唯一的優勢 |
| **知識狀態** | 公主持有的情報集合，驅動對白變體與選項展開 |
| **儀式性重複** | 「女僕進房→項鍊→日期」等表層台詞每輪一致；差異僅在公主的內心獨白與回應動機 |

### 公主視角原則

- **玩家只知道公主知道的事情**：公主未曾目睹的事件、尚未獲得的情報，玩家同樣不得知
- **死亡必然是可見的**：每個 Bad End 中公主都清楚感受到自己的命運
- **對話規則**：公主在對話中只能說「這個回圈中合理知道的事」；內心獨白可回憶任何回圈（見 `.cursor/rules/loop-mechanics.mdc`）

---

## 序章（唯一執行一次）

**主要文件：** `00_prologue/`

固定事件，無分支。城破之夜，公主在寢房驚醒，賽拉斯依密令刺殺。序章結束後情報自動寫入，此情境永久鎖定。

**獲得情報：** `intel_city_fall` / `intel_assassination` / `intel_magic_core_sabotage`

---

## 調查線 A：信任的盲區（宰相線）

**主要文件：** `01_loop_1/` · 詳見 `scenario_A_outline.md`

**核心弧線：** 信任 → 懷疑 → 確認

| 變體 | 公主視角概要 | 結局 | 關鍵情報 |
|---|---|---|---|
| A-0 | 茫然中信任宰相，被親手遞茶毒殺 | Bad End：毒茶 | `intel_chancellor_betrayal` |
| A-1 | 無法信任宰相，轉向賽拉斯；賽拉斯帶傷回來揭露「是宰相」| Bad End：賽拉斯含淚執行密令 | `intel_fake_ledgers` |
| A-2 | 孤注一擲面見父王，小房間中認出茶的氣味 | Bad End：遠程毒殺 | `intel_chancellor_poison` → 調查線 A 鎖定 |

**統一結構**：三輪均以「女僕眼紅→項鍊→三選項」開場，但每輪的內在邏輯完全不同。

---

## 調查線 B：傀儡的絞索（城防漏洞線）

**主要文件：** `02_loop_2/` · 詳見 `scenario_B_outline.md`

**核心弧線：** 求証 → 偽裝 → 滲透

| 變體 | 公主視角概要 | 結局 | 關鍵情報 |
|---|---|---|---|
| B-0 | 本能拒絕項鍊，找女僕出城；發現監視無死角 | Bad End：毒殺（回城或前進路線） | `intel_chancellor_surveillance` / `intel_lower_city_suffering` / `intel_maid_coerced` or `intel_poison_not_just_tea` |
| B-1 | 偽裝順從，連日讀書＋初次接觸達爾學魔法入門；約一週後要城牆地圖觸發殺機 | Bad End：慈愛包裝的毒殺 | `intel_mob_manipulation` / `intel_bruno_wife_death` / `intel_lower_city_route` / `intel_dal_magic_basics` |
| B-2 | 成衣脫身；以**宰相項鍊**向布魯諾換口頭線索後肉身滲透城牆邊界 | Bad End：私兵格殺 | `intel_bruno_passage_tip` ＋ `intel_secret_passage` → 調查線 B 鎖定 |

**B-1 時間感**：非「當日往返即死」——回宮後有**數日至約一週**的讀書／學藝偽裝，才進入城牆地圖與女僕毒茶。

---

## 調查線 C：魔法陣與羅網（達爾線）

**主要文件：** `03_loop_3/` · 詳見 `scenario_C_outline.md`

**核心弧線：** 與達爾建立信任並觀測內鬼（C-0）→ 預警與匿名匯報仍無法救達爾（C-1）→ 向王權和盤托出；父王**以王無法當場採信、以父仍信女**，以高塔隔離；宰相潛逃後短暫平靜、城破，高塔上**破局三選**（C-2）

**進場前提**：B-1 已透過偽裝讀書與初次向達爾學藝取得 `intel_dal_magic_basics`。

| 變體 | 公主視角概要 | 結局 | 關鍵情報 |
|---|---|---|---|
| C-0 | 以認真學生身分接近達爾，約兩個月默背陣式；與達爾在工作室確認腐蝕節點；助手端毒茶、達爾誤飲身亡，公主遭槍殺與嫁禍 | Bad End：達爾毒殺、公主槍殺（現場布置） | `intel_magic_array_mnemonic` / `intel_array_handed_clerk` / `intel_array_structural_passage` / `intel_chancellor_treason`（初稿） |
| C-1 | 提早私下告知達爾並請匿名匯報；達爾仍隔天死亡；公主**僅至陣區門口**遭拒、**未入內**，仍被羅織「違反管制／意圖干預國防」，父王軟禁後毒殺 | Bad End：軟禁後毒殺 | `intel_chancellor_treason`（確認）/ `intel_narrative_flip` / `intel_king_defense_line` |
| C-2 | 向父王和盤托出；父王**信女兒**仍以高塔**保護／隔離**；宰相潛逃後長期虛假和平；茶味再現、女僕線斷、城破、外力全斷→**自選死亡**（破局的抉擇） | Bad End：自選死亡後進入 LOOP 4 | `intel_partial_leak` / `intel_chancellor_escape_plan`（建議） |

> **備註**：「破局的抉擇」（餐刀／冷茶／窗戶三選一）是 **C-2 同一輪迴的後段**，不是獨立章節。三選僅改意象；均導致公主死亡後進入 LOOP 4。唯一受影響之處：終章 D 醒來**首段獨白**依此切換。

---

## 終章 D｜最終輪迴（固定主線）

**主要文件：** `04_loop_4/` · 詳見 `scenario_D_outline.md`

**承接 C-2 結尾（破局的抉擇），為固定主線。** 世界重置，NPC 不記得上輪。公主在本輪重新接觸所有人、同步觸發——她帶走的不是物理種子，而是**情報與記憶**。

**解鎖條件**：`intel_chancellor_treason` ＋ `intel_assassination` ＋ `intel_king_defense_line`（建議同時持有 `intel_magic_array_mnemonic` ＋ `intel_secret_passage`）

**開場**：儀式重複（女僕→項鍊→日期，台詞與前幾輪表層一致）；醒來首段獨白依 C-2「破局的抉擇」選項切換。

**主線步驟**（見 `scenario_D_outline.md`）

| 步驟 | 行動 | 來源／備註 |
|---|---|---|
| 一｜收服賽拉斯 | 密令、糧道／巡邏／盯宰相與退路 | LOOP 0 ＋ A-1 |
| 二｜安撫布魯諾 | 真相＋承諾，奪回下城區敘事 | B-1 |
| 三｜達爾（密談） | 賽拉斯借故引見；術語、慎防副手、朝堂前勿輕動 | C 線；**修復不在此步** |
| 四｜朝堂揭露 | 鐵證攤開；宰相無路可逃→**自盡** | A 全線＋ C 全線 |
| 五｜修復與瓮城 | 進陣區修復／取證；暗道**將計就計**，敵動之日**瓮中捉鱉** | `intel_magic_array_mnemonic` 等 |

**結局**：180 天後敵軍撤退；賽拉斯撕碎密令；破曉。

---

## 公主角色弧線

| 章節 | 主題 | 公主學到什麼 | 核心成長 |
|---|---|---|---|
| 序章 | 死亡 | 城破、密令、陣被內破 | 從無知到恐懼 |
| LOOP 1（A 線） | 信任 | 宰相是敵人，毒茶是手段 | 從信任到確認背叛 |
| LOOP 2（B 線） | 控制 | 監視、操控、密道；偽裝讀書與達爾入門 | 從求證到學會偽裝 |
| LOOP 3（C 線） | 魔法陣 | 默背與內鬼、預警仍無效、交牌與高塔破局 | 從技術線到體制性絕望→主動赴死→多線並行 |
| C-2 後段（破局的抉擇） | 抉擇 | 外力全斷時，唯獨自選之死能斷開輪迴 | 從被殺到主動赴死 |
| 終章 D（LOOP 4） | 覺悟 | 兵／民／術／證同時落地 | 從被保護到保護他人 |

---

## 情報一覽

| 情報 ID | 來源 | 敘事意義 |
|---|---|---|
| `intel_city_fall` | LOOP 0 | 三個月後城破——公主的時限 |
| `intel_assassination` | LOOP 0 | 賽拉斯的密令——終章收服他的關鍵 |
| `intel_magic_core_sabotage` | LOOP 0 | 魔法陣被內部破壞——LOOP 3 的調查起點 |
| `intel_chancellor_betrayal` | A-0 | 「不要怪我」＋茶的氣味——最初的懷疑種子 |
| `intel_fake_ledgers` | A-1 | 帳本與人證均為偽造——信任徹底崩塌 |
| `intel_chancellor_poison` | A-2 | 毒茶確認——宰相殺人手段，調查線 A 鎖定 |
| `intel_chancellor_surveillance` | B-0 | 宰相通過女僕監控——網延伸到身邊每一個人 |
| `intel_lower_city_suffering` | B-0 | 下城區苦難是真實的 |
| `intel_maid_coerced` | B-0（前進路線） | 女僕被脅迫但有良心 |
| `intel_poison_not_just_tea` | B-0（回城路線） | 毒殺不限於茶 |
| `intel_mob_manipulation` | B-1 | 下城區敘事被操控——終章安撫布魯諾的基礎 |
| `intel_lower_city_route` | B-1 | 異常路線與內城牆邊界——鎖定密道方向 |
| `intel_bruno_wife_death` | B-1 | 布魯諾妻子之死——終章情感槓桿 |
| `intel_dal_magic_basics` | B-1 | 達爾魔法入門——C-0 以學生身分進核心的前置 |
| `intel_bruno_passage_tip` | B-2 | 以項鍊向布魯諾換得的口頭線索——與 B-1 路線互證；終章可回扣「押鍊子換真話」 |
| `intel_secret_passage` | B-2 | 城牆密道——物理城防被架空；終章封路 |
| `intel_magic_array_mnemonic` | C-0 | 默背陣式節點——終章技術修復／取證 |
| `intel_array_handed_clerk` | C-0 | 達爾助手異常——維護鏈內鬼抓手 |
| `intel_array_structural_passage` | C-0 | 陣區結構像密道——可選終章雙線封網 |
| `intel_chancellor_treason` | C-0（初稿）／C-1（確認） | 宰相叛國（魔法維護鏈等）——終章必備 |
| `intel_king_defense_line` | B-1 卷宗＋C-1 對齊 | 父王防線全貌——終章必備 |
| `intel_narrative_flip` | C-1 | 技術行為可被翻成叛國——終章須奪話語權 |
| `intel_partial_leak` | C-2 | 父王以父信女、以王囚女——高塔隔離仍無法終局；體制反應本身即線索（見 `LOOP_OUTLINE`） |
| `intel_chancellor_escape_plan` | C-2（建議） | 宰相潛逃後的真空與半年窗口 |
| `intel_dal_blinded_by_chancellor` | 選用支線 | 與現行主線衝突時勿用；僅作舊稿情感加筆 |

---

## 角色速查

| 角色 | 定位 | 核心衝突 |
|---|---|---|
| 公主 艾蓮娜 | 玩家角色 | 唯一「什麼都不知道」的人 |
| 騎士長 賽拉斯 | 序章加害者 / 真最大受害者 | 持有殺死公主的密令，每天祈禱不需執行 |
| 宰相 莫里昂 | 幕後黑手 | 從不說謊，只省略真相 |
| 侍女 莉娜 | 善意的資訊牆 | 用笑容替公主擋住所有壞消息 |
| 工匠 達爾 | 破局的鑰匙 | 魔法陣維護負責人；主線中死於助手毒茶嫁禍（C-0），終章在控場下與公主修復／取證 |
| 鐵匠 布魯諾 | 被操弄的內應 | 妻子死於草藥被軍需徵用，被宰相利用 |
| 國王 | 缺席的父親 | 孤軍奮戰，用名聲換備戰時間 |

---

*權威來源：`dialogic/story_docs/LOOP_OUTLINE.md` | 場景大綱：各 `scenario_*_outline.md` | 角色詳細設定：`docs/zh/design/story/00_Characters.md`*
