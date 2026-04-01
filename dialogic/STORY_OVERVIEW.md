# Break the Loop — 故事線總覽

> 參考來源：`docs/zh/design/story/` 各設計文件

---

## 世界觀與核心前提

王國面臨敵國入侵，宰相莫里昂暗中裡應外合，從內部破壞魔法防護陣、截留救濟糧、操弄暴民。公主艾蓮娜是城堡裡唯一「什麼都不知道」的人，也是唯一能打破輪迴的人。

---

## 公主角色弧線

| LOOP | 心態 | 核心偏見 | 結局 |
|---|---|---|---|
| Loop 0（序章） | 等待被拯救 | 無 | 被賽拉斯依密令刺殺 |
| Loop 1 | 抓住稻草（宰相） | 慈父=暴君 | 被宰相毒茶殺死 |
| Loop 2 | 繞過貴族、信任平民 | 受害者=暴民 | 被布魯諾出賣給敵軍 |
| Loop 3 | 不信任任何人，獨自行動 | 父王是個怪物？ | 被幽禁，在塔樓中拼出真相後自盡 |
| 最終輪迴 | 所有濾鏡剝落 | 無 | 揭露宰相，破城守住 |

---

## Loop 0（序章）

**主要文件：** `00_prologue/`

**關鍵事件：**
1. 城破之夜，公主在寢房中驚醒，完全無知
2. 賽拉斯依國王「絕不能讓公主落入敵手」的密令，含淚刺殺公主

**反轉：** 保護者 = 行刑者

**獲得情報：** `intel_city_fall` / `intel_assassination` / `intel_magic_core_sabotage`

---

## Loop 1

**主要文件：** `01_loop_1/`

**關鍵事件：**
1. 醒來，宰相主動示好，是唯一對她表達善意的人（稻草心理）
2. 宰相展示偽造帳簿，帶公主去下城區目睹苦難
3. 公主被引導去偷城防令印，交給宰相
4. 宰相用毒茶殺死公主，撕下偽裝說明一切

**反轉：** 慈父 = 暴君（帳簿是假的）；宰相的「真相」也是精心篩選的謊言

**分支：**
- `03b_ask_king.dtl`：選擇先問父王（未持有 `intel_king_anger` 才可選）
- 主線必定走向 Bad End A

**獲得情報：** `intel_chancellor_betrayal` / `intel_fake_ledgers` / `intel_chancellor_poison`

---

## Loop 2

**主要文件：** `02_loop_2/`

**關鍵事件：**
1. 醒來，決定不找宰相，直接潛入下城區
2. 在鐵匠布魯諾處做了三十天苦工，建立信任
3. 坦白身份，向布魯諾承諾開糧倉
4. 布魯諾在饑餓與仇恨壓力下，將公主出賣給城外敵軍

**反轉：** 受害者 = 暴民（布魯諾不是壞人，是被逼到絕路的普通人）

**分支：**
- `03b_steal_supplies.dtl`：偷偷回城堡取食物藥品（未持有 `intel_chancellor_eyes` 才可選）
- `04b_rush_granary.dtl`：立刻帶布魯諾去找地下糧倉（未持有 `intel_granary_needs_key` 才可選）
- 主線必定走向 Bad End B

**獲得情報：** `intel_mob_manipulation` / `intel_starvation_real` / `intel_bruno_wife_death`

---

## Loop 3

**主要文件：** `03_loop_3/`

**關鍵事件：**
1. 醒來，決心獨自行動，查清父王真相
2. 在下城區找到盲眼工匠達爾——他說出弄瞎他的人「說話很輕很慢，像在唸詩」
3. 公主發現地下防線：糧倉上鎖（財政署印記=宰相直管）、魔法陣管線遭腐蝕
4. 無法把「唸詩的聲音」與宰相連結，轉而接受「冷血犧牲換保護」的邏輯
5. 宰相察覺，幽禁公主於最高塔樓
6. 塔樓中公主拼出全部真相，但已無法傳遞，選擇自盡

**反轉：** 冷酷帝王 = 溫柔的獻祭者（父王從未是暴君）

**分支：**
- `02b_confront_chancellor.dtl`：拿達爾證詞直接質問宰相（未持有 `intel_chancellor_dismisses_testimony` 才可選）
- `03b_tell_king.dtl`：立刻去告訴父王（未持有 `intel_king_will_listen` 才可選）
- `04b_activate_alone.dtl`：一個人試圖啟動防線（未持有 `intel_defense_needs_three` 才可選）
- 主線必定走向 Bad End C

**獲得情報：** `intel_chancellor_treason` / `intel_king_defense_line` / `intel_dal_blinded_by_chancellor`

---

## 最終輪迴

**主要文件：** `04_final_loop/`

**關鍵事件：**
1. 醒來，帶著完整真相，決心「換我來保護你了」
2. 收服賽拉斯：道出密令，讓他知道「你是唯一會為殺我而哭的人」
3. 安撫布魯諾：「我不是在施捨，是在歸還」
4. 朝堂揭露宰相：出示鐵證，讓他無路可退
5. 180 天後敵軍撤退，賽拉斯撕碎密令，破曉

**三步邏輯：**
| 步驟 | 來源教訓 |
|---|---|
| 收服賽拉斯 | Loop 0：他是被逼殺我的，用理解贏得忠誠 |
| 安撫布魯諾 | Loop 2：暴民被操弄，用真相+實際承諾 |
| 揭露宰相 | Loop 1+3：掌握完整證據鏈，一次出示 |

**分支：**
- `03b_rush_arrest.dtl`：趁宰相不知情直接去抓（未持有 `intel_chancellor_escape_plan` 才可選）

---

## 情報系統（跨輪迴繼承）

情報一旦取得，永久保留並影響後續輪迴的對話分支。

| 情報 ID | 來源 | 解鎖效果 |
|---|---|---|
| `intel_city_fall` | Loop 0 死亡 | 後續違和感追問選項 |
| `intel_assassination` | Loop 0 死亡 | 對賽拉斯特殊對話 |
| `intel_magic_core_sabotage` | Loop 0 死亡 | 魔法陣相關情報基礎 |
| `intel_chancellor_betrayal` | Loop 1 死亡 | 確認宰相是叛徒 |
| `intel_fake_ledgers` | Loop 1 死亡 | 帳簿偽造 |
| `intel_chancellor_poison` | Loop 1 死亡 | 宰相使毒手段 |
| `intel_mob_manipulation` | Loop 2 死亡 | 暴民被操弄 |
| `intel_starvation_real` | Loop 2 死亡 | 下城區饑荒是真的 |
| `intel_bruno_wife_death` | Loop 2 死亡 | 布魯諾妻子死因 |
| `intel_chancellor_treason` | Loop 3 死亡 | 宰相完整罪行 |
| `intel_king_defense_line` | Loop 3 死亡 | 地下防線真相 |
| `intel_dal_blinded_by_chancellor` | Loop 3 死亡 | 達爾被宰相弄瞎 |

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
