# Timeline Rename Map

## Loop 1

EARLY phase 已改為由 `royal_chamber.gd` 直接啟動 `01_loop1_betrayal_awakening.dtl`，不再使用 `00_early_phase_entry.dtl` router。

| Old | New | Route |
| --- | --- | --- |
| `01_awakening.dtl` | `01_loop1_betrayal_awakening.dtl` | betrayal |
| `02_chancellor_visit.dtl` | `02_loop1_betrayal_chancellor_visit.dtl` | betrayal |
| `06_betrayal.dtl` | `03_loop1_betrayal_reveal.dtl` | betrayal |
| `07_bad_end_a.dtl` | `04_loop1_betrayal_badend.dtl` | betrayal |
| `01_awakening_a_v1.dtl` | `05_loop1_ledgers_awakening.dtl` | ledgers |
| `02_chancellor_visit_a_v1.dtl` | `06_loop1_ledgers_chancellor_visit.dtl` | ledgers |
| `07_bad_end_a1.dtl` | `07_loop1_ledgers_badend.dtl` | ledgers |
| `01_awakening_a_v2.dtl` | `08_loop1_poison_awakening.dtl` | poison |
| `02_chancellor_visit_a_v2.dtl` | `09_loop1_poison_chancellor_visit.dtl` | poison |
| `07_bad_end_a2.dtl` | `10_loop1_poison_badend.dtl` | poison |

## Loop 2

`02_loop2_anger_confrontation.dtl` 內已內嵌原本的兩個 anger bad end 分支，結束後統一推進到 surveillance 線。

| Old | New | Route |
| --- | --- | --- |
| `01_awakening_angry.dtl` | `01_loop2_anger_awakening.dtl` | anger |
| `b0_02_confrontation.dtl` | `02_loop2_anger_confrontation.dtl` | anger |
| `b0_03_bad_end.dtl` | merged into `02_loop2_anger_confrontation.dtl` | anger |
| `b0_04_forward_bad_end.dtl` | merged into `02_loop2_anger_confrontation.dtl` | anger |
| `b1_01_awakening.dtl` | `03_loop2_surveillance_awakening.dtl` | surveillance |
| `b1_02_guided_tour.dtl` | `04_loop2_surveillance_guided_tour.dtl` | surveillance |
| `b1_03_return_anomaly.dtl` | `05_loop2_surveillance_return_anomaly.dtl` | surveillance |
| `b1_04_bad_end.dtl` | `06_loop2_surveillance_badend.dtl` | surveillance |
| `b2_01_awakening.dtl` | `07_loop2_passage_awakening.dtl` | passage |
| `b2_02_follow_route.dtl` | `08_loop2_passage_follow_route.dtl` | passage |
| `b2_03_bad_end.dtl` | `09_loop2_passage_badend.dtl` | passage |

## Loop 3

Loop 3 已固定為 `C-0 -> C-1 -> C-2` 的順序推進，不再以 entry router 依持有情報直接跳段。

| Old | New | Route |
| --- | --- | --- |
| `01_awakening_cold.dtl` | `01_loop3_dal_awakening.dtl` | dal |
| `02_approach_dal_c0.dtl` | `02_loop3_dal_approach.dtl` | dal |
| `03_two_months_c0.dtl` | `03_loop3_dal_two_months.dtl` | dal |
| `04_workshop_c0.dtl` | `04_loop3_dal_workshop.dtl` | dal |
| `05_warn_dal_c1.dtl` | `05_loop3_warning_warn_dal.dtl` | warning |
| `06_gate_framed_c1.dtl` | `06_loop3_warning_gate_framed.dtl` | warning |
| `07_meet_king_c2.dtl` | `07_loop3_king_meet_king.dtl` | king |
| `08_tower_c2.dtl` | `08_loop3_king_tower.dtl` | king |
| `09_final_choice_c2.dtl` | `09_loop3_king_final_choice.dtl` | king |

## Final Loop

「直接去抓宰相」已改為 `04_final_main_dal_briefing.dtl` 內部的錯誤選項說明，不再拆成獨立 bad end timeline。

| Old | New | Branch |
| --- | --- | --- |
| `01_awakening_final.dtl` | `01_final_main_awakening.dtl` | MAIN |
| `02_recruit_silas.dtl` | `02_final_main_recruit_silas.dtl` | MAIN |
| `03_calm_mob.dtl` | `03_final_main_calm_mob.dtl` | MAIN |
| `03b_rush_arrest.dtl` | merged into `04_final_main_dal_briefing.dtl` | MAIN |
| `03c_dal_briefing.dtl` | `04_final_main_dal_briefing.dtl` | MAIN |
| `04_expose_chancellor.dtl` | `05_final_main_expose_chancellor.dtl` | MAIN |
| `05_dawn.dtl` | `06_final_goodend_dawn.dtl` | GOODEND |
| `06_epilogue.dtl` | `07_final_goodend_epilogue.dtl` | GOODEND |

## Cleaned Stale Entries

Removed invalid `project.godot` timeline registrations for these missing files:

- `02_infiltration.dtl`
- `03_daily_life.dtl`
- `03_daily_life_b_v1.dtl`
- `03_underground.dtl`
- `03b_steal_supplies.dtl`
- `03b_tell_king.dtl`
- `04_confession.dtl`
- `04_confession_b_v1.dtl`
- `04_confession_b_v2.dtl`
- `04_confession_b_v3.dtl`
- `04_misunderstanding.dtl`
- `04b_activate_alone.dtl`
- `04b_rush_granary.dtl`
- `05_chancellor_strike.dtl`
- `05_mob_trial.dtl`
- `05_mob_trial_b_v2.dtl`
- `05_mob_trial_b_v3.dtl`
- `06_bad_end_b.dtl`
- `06_bad_end_b1.dtl`
- `06_bad_end_b2.dtl`
- `06_bad_end_b3.dtl`
- `06_bad_end_c.dtl`
