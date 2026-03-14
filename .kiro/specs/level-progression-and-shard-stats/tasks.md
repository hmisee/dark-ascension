# Implementation Plan: Level Progression and Shard Stats

## Overview

This plan implements a finite multi-level game loop (Level 1 → Level 2 → Level 1 → Level 2 → Victory), a Boss Wraith enemy for Level 2, boss soul drops, separated shard stat application (attack speed, cooldown reduction, damage amp, soul bonus), and a Victory Screen. Tasks are ordered by dependency: progression state first, then the new boss, then level-aware spawning, then stat fixes, then UI, then integration wiring.

## Tasks

- [x] 1. Add level progression state to GameManager
  - [x] 1.1 Add `current_level` and `current_cycle` properties, `advance_level()`, and `is_final_level()` to `scripts/autoloads/game_manager.gd`
    - Add `var current_level: int = 1` and `var current_cycle: int = 1`
    - Implement `advance_level()`: if level == 1, set level to 2; if level == 2, set level to 1 and increment cycle. No-op if already at final level (cycle 2, level 2)
    - Implement `is_final_level() -> bool`: returns `current_cycle == 2 and current_level == 2`
    - _Requirements: 3.1, 3.2, 6.1, 6.2, 6.3, 6.4_

  - [x] 1.2 Update `start_new_run()` to reset `current_level` and `current_cycle` to 1
    - _Requirements: 3.3, 14.1_

  - [x] 1.3 Update `save_run_state()` to include `current_level` and `current_cycle`, and `load_run_state()` to restore them (defaulting to 1 if missing)
    - _Requirements: 6.5, 8.2_

  - [ ]* 1.4 Write property tests for level progression (tests/test_level_progression.gd)
    - **Property 1: Level progression advance produces correct next state**
    - **Validates: Requirements 6.1, 6.2, 6.3**

  - [ ]* 1.5 Write property test for run state round-trip
    - **Property 2: Run state serialization round-trip preserves progression**
    - **Validates: Requirements 6.5, 8.2**

  - [ ]* 1.6 Write property test for new run reset
    - **Property 3: New run resets progression state**
    - **Validates: Requirements 3.3, 14.1**

- [x] 2. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Create Boss Wraith enemy
  - [x] 3.1 Create `scripts/entities/boss_wraith.gd` extending `GhostEnemy`
    - Set `max_health = 250.0`, `move_speed = 50.0`, `contact_damage = 15.0`, `soul_value = 75`, `attack_cooldown = 1.5`, `scale = Vector2(2.0, 2.0)`
    - Emit `boss_defeated` signal in `die()`, then call `super.die()`
    - Mirror the `BossSkeleton` pattern exactly
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 3.2 Create `scenes/boss_wraith.tscn` scene
    - Mirror `scenes/boss_skeleton.tscn` structure: `CharacterBody2D` root with `AnimatedSprite2D`, `HealthBar`, `CollisionShape2D`
    - Attach `boss_wraith.gd` script, use ghost enemy sprites at 2x scale
    - _Requirements: 1.1_

  - [x] 3.3 Verify `BossSkeleton` already spawns a soul drop on death via inherited `Enemy.die()` → `_spawn_soul_drop()`
    - Confirm `soul_value = 50` is set and `super.die()` is called in `BossSkeleton.die()`
    - No code change expected; if soul drop is missing, add `_spawn_soul_drop()` call
    - _Requirements: 2.1, 2.3_

- [x] 4. Make LevelManager level-aware
  - [x] 4.1 Add `BOSS_WRAITH_SCENE_PATH` constant and update `_start_boss_phase()` to read `GameManager.current_level` and spawn `BossWraith` for level 2, `BossSkeleton` for level 1
    - Default to `BossSkeleton` if `current_level` has an unexpected value
    - Connect `boss_defeated` signal for whichever boss is spawned
    - _Requirements: 4.1, 5.1, 3.4_

  - [x] 4.2 Update `_clear_regular_enemies()` to also exclude `BossWraith` from clearing
    - _Requirements: 5.1_

  - [x] 4.3 Update `_on_boss_defeated()` to call `GameManager.advance_level()` before `_on_level_complete()`
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 4.4 Update `_on_level_complete()` to show `VictoryScreen` if `GameManager.is_final_level()`, otherwise show the existing post-level popup
    - _Requirements: 6.4, 7.1_

  - [x] 4.5 Update `_on_continue_pressed()` to save run state (including level/cycle) before scene transition
    - _Requirements: 8.1, 8.3_

- [x] 5. Separate attack speed and cooldown reduction in StatBonusApplier
  - [x] 5.1 Update `_apply_to_player()` in `scripts/systems/stat_bonus_applier.gd` to use only `ATTACK_SPEED` for `attack_cooldown` reduction (not combined with `COOLDOWN_REDUCTION`)
    - Formula: `base_cd * max(0.1, 1.0 - atk_speed_pct / 100.0)`
    - _Requirements: 9.1, 9.3_

  - [x] 5.2 Update `_apply_to_shadows()` to use only `ATTACK_SPEED` for shadow `attack_cooldown` reduction
    - Formula: `base_cd * max(0.1, 1.0 - atk_speed_pct / 100.0)`
    - _Requirements: 9.2, 9.3_

  - [x] 5.3 Add `resurrection_cooldown_multiplier` property to `StatBonusApplier`, computed as `max(0.1, 1.0 - cd_reduce_pct / 100.0)` in `apply_bonuses()`
    - _Requirements: 10.1, 10.3_

  - [x] 5.4 Update `ShadowResurrectionSystem.on_shadow_died()` to read effective cooldown from `StatBonusApplier` instead of hardcoded `resurrection_cooldowns` values
    - Effective cooldown = `base_cooldown * StatBonusApplier.resurrection_cooldown_multiplier`
    - _Requirements: 10.2_

  - [ ]* 5.5 Write property test for attack speed cooldown reduction
    - **Property 4: Attack speed reduces attack cooldown with floor clamp**
    - **Validates: Requirements 9.1, 9.2**

  - [ ]* 5.6 Write property test for stat independence
    - **Property 5: Attack speed and cooldown reduction are independent stats**
    - **Validates: Requirements 9.3**

  - [ ]* 5.7 Write property test for cooldown reduction on resurrection
    - **Property 6: Cooldown reduction reduces resurrection cooldown with floor clamp**
    - **Validates: Requirements 10.1, 10.3**

- [x] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Implement damage amp and soul bonus stat application
  - [x] 7.1 Update `Projectile._on_body_entered()` in `scripts/entities/projectile.gd` to read `damage_amp` from `StatBonusApplier` at impact time and apply multiplier `base_damage * (1.0 + damage_amp / 100.0)`
    - Access `StatBonusApplier` via `Autoloads.game_manager().stat_bonus_applier`
    - If `StatBonusApplier` is not accessible, use base damage without modification
    - _Requirements: 12.1, 12.3_

  - [x] 7.2 Update `SoulDrop._on_body_entered()` in `scripts/entities/soul_drop.gd` to read `soul_bonus` from `StatBonusApplier` and apply multiplier `round(soul_value * (1.0 + soul_bonus / 100.0))`
    - If `StatBonusApplier` is not accessible, use raw `soul_value`
    - _Requirements: 13.1, 13.2_

  - [ ]* 7.3 Write property test for damage amplification
    - **Property 7: Damage amplification formula**
    - **Validates: Requirements 12.1**

  - [ ]* 7.4 Write property test for soul bonus with rounding
    - **Property 8: Soul bonus formula with rounding**
    - **Validates: Requirements 13.1, 13.2, 2.3**

- [x] 8. Create Victory Screen UI
  - [x] 8.1 Create `scripts/ui/victory_screen.gd` extending `Control` following the `FailureScreen` pattern
    - Add `new_run_pressed` and `menu_pressed` signals
    - Build UI programmatically in `_build_ui()`: congratulatory title, total soul energy label, "New Run" button, "Main Menu" button
    - Style consistently with `FailureScreen`
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

  - [x] 8.2 Wire `VictoryScreen` into `LevelManager._on_level_complete()`
    - Connect `new_run_pressed` to call `GameManager.start_new_run()`, clear `_saved_run_state`, unpause, and load boss level scene
    - Connect `menu_pressed` to clear `_saved_run_state`, unpause, and load main menu
    - Show via `CanvasLayer` at layer 10 with `PROCESS_MODE_ALWAYS`, same as `FailureScreen`
    - _Requirements: 7.1, 7.4, 7.5_

- [x] 9. Update post-level screen and shop for level-aware transitions
  - [x] 9.1 Replace the existing `_show_victory_popup()` in `LevelManager` with a proper `PostLevelScreen` that shows "Next Level" and "Go to Shop" buttons (instead of the current "Boss Defeated" popup)
    - Rename or refactor the method to `_show_post_level_screen()`
    - "Next Level" calls `_on_continue_pressed()` which saves run state and reloads boss level
    - "Go to Shop" calls `_on_shop_pressed()` which saves run state and loads shop scene
    - _Requirements: 8.1, 8.2_

  - [x] 9.2 Ensure `ShopScene._on_next_level()` saves run state (including level/cycle) before transitioning to boss level
    - _Requirements: 8.3_

- [x] 10. Wire stat bonus registration on level load
  - [x] 10.1 Ensure `Player` registers with `StatBonusApplier` during initialization in the boss level scene
    - Call `Autoloads.game_manager().stat_bonus_applier.register_player(self)` in player `_ready()` or in `LevelManager.start_level()`
    - _Requirements: 11.1_

  - [x] 10.2 Ensure each `Shadow` registers with `StatBonusApplier` when spawned
    - Call `register_shadow(self)` during shadow initialization
    - _Requirements: 11.2_

  - [x] 10.3 Call `StatBonusApplier.apply_bonuses()` after all entities are registered in `LevelManager.start_level()`
    - Also call after `load_run_state()` restores the relic grid
    - _Requirements: 11.3, 11.4_

- [x] 11. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests use the existing `PropertyTestRunner` at `tests/helpers/property_test_runner.gd` with GdUnit4
- Test files: `tests/test_level_progression.gd` (Properties 1–3), `tests/test_stat_application.gd` (Properties 4–8)
- The `BossWraith` mirrors the `BossSkeleton` pattern exactly — extends base enemy class, overrides stats, emits `boss_defeated`
- Boss soul drops already work via inherited `Enemy.die()` → `_spawn_soul_drop()` — no new mechanism needed
