# Implementation Plan: Game Audio System

## Overview

Implement a complete audio system for Dark Ascension using Godot's AudioServer bus architecture. The plan proceeds incrementally: audio bus layout → AudioManager autoload with BGM/crossfade/SFX → OptionsManager volume extensions → UI sliders → entity and scene integration points. Each step builds on the previous and ends with full wiring.

## Tasks

- [x] 1. Create audio bus layout and register AudioManager autoload
  - [x] 1.1 Create `default_bus_layout.tres` with Master, Music, and SFX buses
    - Define bus 0 "Master" (default output), bus 1 "Music" routed to Master, bus 2 "SFX" routed to Master
    - Reference the layout in `project.godot` under `[audio]`
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 1.2 Create `scripts/autoloads/audio_manager.gd` skeleton and register as autoload
    - Create the AudioManager script extending Node
    - Register it in `project.godot` autoloads
    - Add `audio_manager()` helper to `scripts/autoloads/autoload_helper.gd`
    - _Requirements: 2.1_

- [x] 2. Implement AudioManager BGM playback and preloading
  - [x] 2.1 Implement audio resource preloading in `_ready()`
    - Preload all BGM tracks (`menu`, `wave`, `boss`) and SFX clips (`player_hit`, `player_death`, `player_attack`, `enemy_hit`, `enemy_death`, `shadow_death`, `boss_defeat`) into dictionaries
    - Create 2 `AudioStreamPlayer` child nodes for BGM on the "Music" bus
    - Create 8 `AudioStreamPlayer` child nodes for SFX on the "SFX" bus
    - Log warnings for any missing audio resources
    - _Requirements: 2.4, 15.1, 15.2, 15.3_

  - [x] 2.2 Implement `play_bgm(track_name)` with idempotence check
    - If `track_name` matches `_current_bgm`, return immediately (no restart)
    - If no BGM is playing, start playback on the active BGM player at full volume
    - Warn and return if `track_name` is not in `_bgm_tracks`
    - _Requirements: 2.2, 2.5, 3.4, 4.2, 5.2_

  - [x] 2.3 Implement `stop_bgm()` and `get_current_bgm()`
    - `stop_bgm()` stops both BGM players and clears `_current_bgm`
    - `get_current_bgm()` returns `_current_bgm`
    - _Requirements: 2.2_

  - [ ]* 2.4 Write property test for BGM idempotence (Property 3)
    - **Property 3: BGM idempotence**
    - Calling `play_bgm` with the same track name should not restart playback
    - **Validates: Requirements 2.5, 3.2**

- [x] 3. Implement BGM crossfade transitions
  - [x] 3.1 Implement crossfade logic in `play_bgm` when switching tracks
    - When a different track is requested while one is playing, use a `Tween` to fade out the current BGM player and fade in the alternate BGM player over 1.5 seconds
    - Linearly decrease outgoing volume from current level to `-80 dB` (silence)
    - Linearly increase incoming volume from `-80 dB` to `0 dB` (full)
    - Swap `_active_bgm_index` and update `_current_bgm`
    - _Requirements: 6.1, 6.2, 6.3_

  - [x] 3.2 Handle crossfade interruption
    - If a new `play_bgm` is called during an active crossfade, kill the current `_crossfade_tween` (check `is_instance_valid()`) and start a new crossfade from the current volume state
    - _Requirements: 6.4_

  - [ ]* 3.3 Write property test for crossfade between different tracks (Property 4)
    - **Property 4: Crossfade between different BGM tracks**
    - After crossfade completes, the new track should be active at full volume and the old track silent
    - **Validates: Requirements 6.1**

  - [ ]* 3.4 Write property test for crossfade interruption (Property 5)
    - **Property 5: Crossfade interruption resolves to last requested track**
    - Rapid successive `play_bgm` calls should resolve to the last requested track
    - **Validates: Requirements 6.4**

- [x] 4. Checkpoint - Ensure BGM playback and crossfade work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement SFX playback with polyphony
  - [x] 5.1 Implement `play_sfx(sfx_name)` with channel pool
    - Find the first non-playing SFX player and use it
    - If all 8 are busy, find the one closest to completion (highest `get_playback_position()` relative to stream length) and reuse it
    - Assign the preloaded `AudioStream` and call `play()`
    - Warn and return if `sfx_name` is not in `_sfx_clips`
    - _Requirements: 2.3, 12.1, 12.2_

  - [ ]* 5.2 Write property test for BGM on Music bus (Property 1)
    - **Property 1: BGM plays on Music bus**
    - Any BGM playback should use the "Music" bus
    - **Validates: Requirements 2.2**

  - [ ]* 5.3 Write property test for SFX on SFX bus (Property 2)
    - **Property 2: SFX plays on SFX bus**
    - Any SFX playback should use the "SFX" bus
    - **Validates: Requirements 2.3**

  - [ ]* 5.4 Write property test for SFX channel allocation (Property 8)
    - **Property 8: SFX channel allocation and reuse**
    - First 8 concurrent SFX use distinct channels; 9th reuses the one closest to completion
    - **Validates: Requirements 12.1, 12.2**

- [x] 6. Extend OptionsManager with volume controls
  - [x] 6.1 Add volume state and methods to `scripts/autoloads/options_manager.gd`
    - Add `master_volume`, `music_volume`, `sfx_volume` variables (default 100)
    - Implement `apply_volume(bus_name, value)` — convert 0-100 to dB via `linear_to_db(value / 100.0)`, mute bus when value is 0, clamp input to [0, 100]
    - Implement `_volume_to_db(value)` helper
    - Check `AudioServer.get_bus_index()` for -1 and warn
    - _Requirements: 13.4, 13.5_

  - [x] 6.2 Extend `save_settings()` and `load_settings()` for audio persistence
    - Add `[audio]` section with `master_volume`, `music_volume`, `sfx_volume` to the ConfigFile
    - On load, use defaults of 100 if keys are missing
    - Apply loaded volumes to AudioServer on startup
    - Extend `reset_to_defaults()` to set all volumes to 100
    - _Requirements: 13.6, 13.7_

  - [ ]* 6.3 Write property test for volume application (Property 9)
    - **Property 9: Volume application to AudioServer**
    - `apply_volume` should correctly set AudioServer bus volume for any bus and value in [0, 100]
    - **Validates: Requirements 13.4, 13.5**

  - [ ]* 6.4 Write property test for volume persistence round-trip (Property 10)
    - **Property 10: Volume settings persistence round-trip**
    - Save then load should restore exact volume values
    - **Validates: Requirements 13.6, 13.7**

- [x] 7. Add volume sliders to options menu UI
  - [x] 7.1 Add Master, Music, and SFX `HSlider` nodes to `scenes/options_menu.tscn` and wire in `scripts/ui/options_menu.gd`
    - Add three sliders with range 0-100, step 1
    - Read initial values from `OptionsManager` on menu open
    - Connect `value_changed` to `OptionsManager.apply_volume()` for live preview
    - Persist on Apply, revert on Cancel using the existing snapshot pattern
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

- [x] 8. Checkpoint - Ensure AudioManager and volume controls work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Integrate BGM triggers in scene and level scripts
  - [x] 9.1 Add `AudioManager.play_bgm("menu")` calls to menu and shop scenes
    - Add call in `main_menu.gd` `_ready()`
    - Add call in `shop_scene.gd` `_ready()`
    - _Requirements: 3.1, 3.3_

  - [x] 9.2 Add BGM triggers to `scripts/systems/level_manager.gd`
    - Call `AudioManager.play_bgm("wave")` when wave phase starts
    - Call `AudioManager.play_bgm("boss")` when boss phase starts
    - Call `AudioManager.play_bgm("menu")` on level complete and level failed
    - _Requirements: 4.1, 5.1, 14.1, 14.2_

- [x] 10. Integrate SFX triggers in entity scripts
  - [x] 10.1 Add SFX calls to `scripts/entities/player.gd`
    - In `take_damage()`: play "player_hit" if health > 0 after damage, "player_death" if health <= 0
    - In `spawn_projectile()`: play "player_attack"
    - _Requirements: 7.1, 7.2, 8.1_

  - [ ]* 10.2 Write property test for player damage SFX selection (Property 6)
    - **Property 6: Player damage SFX selection**
    - Correct SFX chosen based on remaining health after damage
    - **Validates: Requirements 7.1, 7.2**

  - [x] 10.3 Add SFX calls to `scripts/entities/enemy.gd`
    - In `take_damage()`: play "enemy_hit" if health > 0 after damage
    - In `die()`: play "enemy_death"
    - _Requirements: 9.1, 9.2_

  - [ ]* 10.4 Write property test for enemy damage SFX (Property 7)
    - **Property 7: Enemy damage SFX on non-lethal hit**
    - Non-lethal hits play "enemy_hit"
    - **Validates: Requirements 9.1**

  - [x] 10.5 Add SFX calls to `scripts/entities/shadow.gd`
    - In `die()`: play "shadow_death"
    - _Requirements: 10.1_

  - [x] 10.6 Add SFX calls to boss scripts
    - In `scripts/entities/boss_skeleton.gd` `die()`: play "boss_defeat"
    - In `scripts/entities/boss_wraith.gd` `die()`: play "boss_defeat"
    - _Requirements: 11.1_

- [x] 11. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests use the existing `PropertyTestRunner` helper in `tests/helpers/property_test_runner.gd`
- Test files: `tests/test_audio_manager.gd` (BGM, SFX, crossfade) and `tests/test_audio_options.gd` (volume controls)
- All audio assets (`.ogg` files) are expected to be placed in `assets/audio/music/` and `assets/audio/sfx/` before running the game
