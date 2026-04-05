# 已知問題清單

## 已修復

- **灰畫面 bug**（三選項多選結構）  
  `01_loop_1/01_awakening.dtl`、`01_awakening_a_v1.dtl`、`01_awakening_a_v2.dtl`  
  選完前三個選項後，因為缺少 `jump` 導致 timeline 結束、出現灰畫面。  
  修法：在選項區塊前加 `label choice_loop`，每個非終止選項結尾補 `jump choice_loop`。  
  **狀態：✅ 已修復**

---

## 待確認 / 待修正

### 1. `hollow` 表情使用範圍問題

根據角色表情規範，`hollow` **僅限**多次輪迴後的麻木（Loop 3 末尾塔樓、Loop 2 Bad End 被出賣後）。以下檔案的 `hollow` 需確認是否符合：

- `01_loop_1/01_awakening_a_v1.dtl` 第 10 行  
  `princess (hollow): ……又是這個房間。`  
  情境：Loop 1 第一次被毒死後醒來，標題「帶著疑惑醒來」  
  → 建議改為 `shocked`（初次死亡、困惑大於麻木）

- `01_loop_1/01_awakening_a_v2.dtl` 第 10、44、51 行  
  情境：Loop 1 第三次醒來，標題「孤注一擲與絕對的絕望」  
  → 第 10 行同段後已出現 `cold` 表情，確認開場是否改為 `cold` 或保留 `hollow`

- `02_loop_2/01_awakening_angry.dtl` 第 17 行  
  `princess (hollow): ……又回來了。`  
  情境：Loop 2 基底版，情緒主線為憤怒  
  → 建議改為 `angry`（與 Loop 2 整體基調一致）

- `02_loop_2/01_awakening_b_v1.dtl` 第 10 行  
  `02_loop_2/01_awakening_b_v2.dtl` 第 10 行  
  `02_loop_2/01_awakening_b_v3.dtl` 第 10 行  
  情境：Loop 2 各變體版，開場「……又回來了。」後迅速轉為 `determined`  
  → 確認是否為「憤怒前的短暫空白」意圖表達，或統一改為 `angry`

### 2. `02_loop_2/01_awakening_b_v1.dtl` — `hollow` 表情出現在非麻木情境

第 10 行同上，但全篇情緒核心為「要帶真正有用的東西」（行動導向），`hollow` 與內文情緒落差較大。建議 `sad` 或 `angry` 擇一。

### 3. 建議確認：所有 Loop 2 awakening 開場的表情一致性

Loop 2 基底（`angry.dtl`）和各 v1/v2/v3 變體的開場表情目前不一致（有 `hollow` 有 `angry`），建議統一。
