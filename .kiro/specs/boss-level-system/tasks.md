# Implementation Plan: Boss Level System

## Overview

Implement a boss level system for Dark Ascension with a survival timer, boss skeleton enemy, level manager, and post-level UI screens. The implementation follows an incremental approach: entity first, then player modifications, core systems, UI, scene wiring, and finally tests.

## Tasks

- [x] 1. Create BossSkeleton entity
  - [x] 1.1 Create `scripts/entities/boss_skeleton.gd` extending SkeletonEnemy
    - Override `_ready()` to set: `max_health = 200.0`, `move_speed = 70.0`, `contact_damage = 20.0`, `soul_value = 50`, `scale = Vector2(2.0, 2.0)`
    - Add `signal boss_defeated` and emit it in `die()` before calling `super.die()`
    - Set `current_health = max_health` and call `update_health_bar()`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

  - [x] 1.2 Create `scenes/boss_skeleton.tscn` scene
    - Duplicate `scenes/skeleton_enemy.tscn` and attach `boss_skeleton.gd` script
    - _Requirements: 2.1_

  - [ ]* 1.3 Write unit tests for BossSkeleton stats
    - Verify inheritance: `boss is SkeletonEnemy`
    - Verify stat overrides: max_health=200, move_speed=70, contact_damage=20, soul_value=50, scale=Vector2(2,2)
    - Verify `boss_defeated` signal is emitted on death
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

- [x] 2. Modify Player for managed level support
  - [x] 2.1 Add `player_died` signal and `managed_level` flag to `scripts/entities/player.gd`
    - Add `signal player_died` at the top of the class
    - Add `var managed_level: bool = false`
    - Modify `die()` to emit `player_died` and only call `reload_current_scene` if `not managed_level`
    - _Requirements: 1.4_

- [x] 3. Implement LevelManager system
  - [x] 3.1 Create `scripts/systems/level_manager.gd` with level state machine
    - Define `LevelState` enum: `INITIALIZING, RUNNING, COMPLETE, FAILED`
    - Add exports: `survival_time: float = 20.0`, `boss_spawn_distance: float = 400.0`, `enable_enemy_spawner: bool = false`
    - Add signals: `level_completed`, `level_failed`
    - Track `time_remaining`, `state`, `boss`, `player` references
    - _Requirements: 1.1, 3.5_

  - [x] 3.2 Implement `start_level()` in LevelManager
    - Call `GameManager.load_run_state()` to restore previous state
    - Position player at center of arena (Vector2.ZERO)
    - Spawn BossSkeleton at `boss_spawn_distance` pixels from player
    - Connect to `player.player_died` signal, set `player.managed_level = true`
    - Connect to `boss.boss_defeated` signal
    - Set `time_remaining = survival_time`, transition state to `RUNNING`
    - Disable EnemySpawner if present and `enable_enemy_spawner` is false
    - _Requirements: 1.1, 3.1, 3.2, 3.3, 3.4, 7.2_

  - [x] 3.3 Implement timer countdown in `_physics_process(delta)`
    - Decrement `time_remaining` by delta while state is `RUNNING`
    - Clamp `time_remaining` to 0.0 minimum
    - When `time_remaining` reaches 0, call `_on_level_complete()`
    - _Requirements: 1.2, 1.3_

  - [x] 3.4 Implement `_on_level_complete()` and `_on_level_failed()`
    - `_on_level_complete()`: set state to `COMPLETE`, remove boss if alive (`is_instance_valid` check), call `GameManager.award_relic()`, emit `level_completed`, show PostLevelScreen
    - `_on_level_failed()`: set state to `FAILED`, remove boss if alive, emit `level_failed`, show FailureScreen
    - _Requirements: 1.3, 1.4, 4.1, 4.2, 4.6, 5.1, 5.2_

  - [x] 3.5 Implement level transition methods
    - `_on_continue_pressed()`: call `GameManager.save_run_state()`, reload boss level scene for next level
    - `_on_retry_pressed()`: call `GameManager.start_new_run()`, reload boss level scene
    - `_on_menu_pressed()`: change scene to main menu
    - _Requirements: 5.5, 7.1_

  - [x] 3.6 Add static helper functions `format_time()` and `get_timer_color()`
    - `format_time(seconds: float) -> String`: above 10s return ceili as string, 0-10s return one decimal, <=0 return "0.0"
    - `get_timer_color(seconds: float) -> Color`: return RED if <=5.0, WHITE otherwise
    - _Requirements: 6.2, 6.3, 6.4_

  - [ ]* 3.7 Write property test: Timer initialization matches configuration (Property 1)
    - **Property 1: Timer initialization matches configuration**
    - Generate random positive survival time values, call start_level logic, verify `time_remaining == survival_time` and state is `RUNNING`
    - **Validates: Requirements 1.1**

  - [ ]* 3.8 Write property test: Timer expiry triggers level completion (Property 2)
    - **Property 2: Timer expiry triggers level completion**
    - Generate random RUNNING states where time reaches zero, verify state transitions to COMPLETE
    - **Validates: Requirements 1.3**

  - [ ]* 3.9 Write property test: Player death triggers level failure (Property 3)
    - **Property 3: Player death triggers level failure**
    - Generate random RUNNING states with time_remaining > 0, simulate player death, verify state transitions to FAILED
    - **Validates: Requirements 1.4**

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement SurvivalTimerHUD
  - [x] 5.1 Create `scripts/ui/survival_timer_hud.gd`
    - Extend `Label`, class_name `SurvivalTimerHUD`
    - Accept a reference to LevelManager (or find via group)
    - In `_process(delta)`, read `time_remaining` from LevelManager
    - Call `LevelManager.format_time()` for display text
    - Call `LevelManager.get_timer_color()` for text color
    - Position at top center of screen
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ]* 5.2 Write property test: Timer formatting rules (Property 4)
    - **Property 4: Timer formatting rules**
    - Generate random floats 0.01-60.0, verify format_time output: >10 returns ceili string, (0,10] returns one decimal, <=0 returns "0.0"
    - **Validates: Requirements 1.2, 6.2, 6.3**

  - [ ]* 5.3 Write property test: Timer color threshold (Property 5)
    - **Property 5: Timer color threshold**
    - Generate random floats 0.01-60.0, verify get_timer_color returns RED iff <=5.0, WHITE otherwise
    - **Validates: Requirements 6.4**

- [x] 6. Implement PostLevelScreen and FailureScreen UI
  - [x] 6.1 Create `scripts/ui/post_level_screen.gd`
    - Extend `Control`, class_name `PostLevelScreen`
    - Add signals: `continue_pressed`, `menu_pressed`
    - Display total soul energy earned (read from SoulEnergyManager)
    - Instantiate and embed `ShardShopUI` and `RelicGridUI`
    - Call `GameManager.shard_shop.generate_offers()` when shown
    - Add "Next Level" and "Main Menu" buttons wired to signals
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.7_

  - [x] 6.2 Create `scripts/ui/failure_screen.gd`
    - Extend `Control`, class_name `FailureScreen`
    - Add signals: `retry_pressed`, `menu_pressed`
    - Display "You Died" text as a centered Label
    - Add "Retry" and "Main Menu" buttons wired to signals
    - _Requirements: 5.2, 5.3, 5.4_

  - [ ]* 6.3 Write unit tests for PostLevelScreen and FailureScreen
    - Verify FailureScreen contains "You Died" label text
    - Verify FailureScreen has retry and menu buttons
    - Verify PostLevelScreen has ShardShopUI and RelicGridUI children
    - Verify PostLevelScreen has continue and menu buttons
    - _Requirements: 4.4, 4.5, 4.7, 5.2, 5.3, 5.4_

- [x] 7. Create boss level scene and wire everything together
  - [x] 7.1 Create `scenes/dungeon/boss_level.tscn`
    - Root Node2D with LevelManager script attached
    - Add ColorRect background
    - Instance `player.tscn` as child
    - Add EnemySpawner Node2D (disabled by default)
    - Add CanvasLayer with SurvivalTimerHUD child
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 7.2 Wire LevelManager to UI screens
    - Connect `level_completed` to show PostLevelScreen overlay
    - Connect `level_failed` to show FailureScreen overlay
    - Connect PostLevelScreen `continue_pressed` and `menu_pressed` to LevelManager transition methods
    - Connect FailureScreen `retry_pressed` and `menu_pressed` to LevelManager transition methods
    - Call `start_level()` in LevelManager `_ready()`
    - _Requirements: 4.2, 5.2, 5.5, 7.1, 7.2_

  - [ ]* 7.3 Write property test: Boss spawn distance from player (Property 6)
    - **Property 6: Boss spawn distance from player**
    - Generate random Vector2 player positions, compute spawn position, verify distance is 400 pixels (within float tolerance)
    - **Validates: Requirements 3.1**

  - [ ]* 7.4 Write property test: Arena cleanup on any terminal state (Property 7)
    - **Property 7: Arena cleanup on any terminal state**
    - Generate random terminal states (COMPLETE/FAILED) and boss alive/dead combinations, verify boss node is removed from scene tree
    - **Validates: Requirements 4.1, 5.1**

- [x] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Implement run state persistence and relic award
  - [x] 9.1 Wire run state save/load into LevelManager transitions
    - Call `GameManager.save_run_state()` in `_on_continue_pressed()` before scene transition
    - Call `GameManager.load_run_state()` in `start_level()` at level initialization
    - Verify soul energy, relic grid, and shard inventory persist across transitions
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ]* 9.2 Write property test: Award relic idempotence (Property 8)
    - **Property 8: Award relic idempotence**
    - Generate random sequences of `award_relic()` calls (1-5 times) with random initial unlock state, verify `is_relic_unlocked()` always returns true and multiple calls have same effect as one
    - **Validates: Requirements 4.6**

  - [ ]* 9.3 Write property test: Run state save/load round trip (Property 9)
    - **Property 9: Run state save/load round trip**
    - Generate random soul energy, random relic grid placements, random shard inventories, round-trip through save_run_state/load_run_state, verify equivalence
    - **Validates: Requirements 7.3**

- [x] 10. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties from the design document
- The project uses GDScript with GdUnit4 test framework and a custom PropertyTestRunner
- Checkpoints ensure incremental validation at key integration points
- BossSkeleton is spawned dynamically by LevelManager, not placed in the scene tree statically
