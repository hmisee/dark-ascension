# Implementation Plan: Game Options System

## Overview

Implement the Game Options System for Dark Ascension in GDScript/Godot 4. The plan starts with the OptionsManager autoload singleton (state, persistence, input rebinding), then builds the OptionsMenu UI scene, wires it into the MainMenu, and registers the autoload in project.godot. Property-based tests and unit tests validate correctness throughout.

## Tasks

- [x] 1. Implement OptionsManager autoload singleton
  - [x] 1.1 Create `scripts/autoloads/options_manager.gd` with constants, state, and defaults
    - Define RESOLUTIONS, DISPLAY_MODES, ACTIONS, DEFAULT_BINDINGS, SETTINGS_PATH constants
    - Define state variables: display_mode, resolution_index, key_bindings
    - Implement `reset_to_defaults()` to set all state to default values
    - Implement `_ready()` to call `load_settings()` and fall back to `reset_to_defaults()` on failure, then apply display and input settings
    - _Requirements: 1.1, 3.4, 5.4_

  - [x] 1.2 Implement display mode and resolution application
    - Implement `apply_display_mode(mode: int)` using DisplayServer to set fullscreen, borderless, or windowed mode; resize window if windowed
    - Implement `apply_resolution(index: int)` to update viewport size and resize window when in windowed mode
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 3.2, 3.3_

  - [x] 1.3 Implement key rebinding with swap-on-conflict
    - Implement `rebind_key(action: String, new_keycode: int)` — assign new key, swap if conflict with another WASD action
    - Implement `apply_key_bindings()` — rebuild InputMap events for all four WASD actions, preserving non-WASD events (arrow keys)
    - _Requirements: 4.3, 4.4, 4.5, 4.6_

  - [x] 1.4 Implement settings persistence (save/load via ConfigFile)
    - Implement `save_settings()` — write display_mode, resolution_index, key_bindings to ConfigFile at `user://settings.cfg`
    - Implement `load_settings() -> bool` — read ConfigFile, clamp/validate values, return false on failure
    - Handle corrupted/missing file by returning false so `_ready()` falls back to defaults
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 1.5 Implement snapshot and revert for cancel flow
    - Implement `get_settings_snapshot() -> Dictionary` — deep copy of current state
    - Implement `apply_snapshot(snapshot: Dictionary)` — restore state and re-apply display + input
    - _Requirements: 6.4_

- [x] 2. Register OptionsManager autoload in project.godot
  - Add `OptionsManager="*res://scripts/autoloads/options_manager.gd"` to the `[autoload]` section of `project.godot`
  - _Requirements: 1.1, 1.2, 5.3_

- [x] 3. Checkpoint — Verify OptionsManager core logic
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Create OptionsMenu UI scene and script
  - [x] 4.1 Create `scenes/options_menu.tscn` scene with node tree
    - Build Control scene with PanelContainer > VBoxContainer containing: TitleLabel, DisplayModeOption (OptionButton), ResolutionOption (OptionButton), KeyBind rows (4× HBoxContainer with Label + Button), ApplyButton, CancelButton
    - _Requirements: 2.1, 3.1, 4.1, 6.2, 6.3_

  - [x] 4.2 Create `scripts/ui/options_menu.gd` script
    - Implement `open()` — snapshot settings, populate UI controls from OptionsManager state, show menu
    - Implement `_on_apply_pressed()` — commit UI selections to OptionsManager, call save_settings(), emit close signal
    - Implement `_on_cancel_pressed()` — call OptionsManager.apply_snapshot() with saved snapshot, emit close signal
    - Implement `_on_rebind_button_pressed(action)` — enter listening state, update button text to "Press a key..."
    - Implement `_unhandled_input(event)` — if listening and InputEventKey pressed, call rebind_key(), update UI, exit listening; if Escape, cancel rebind
    - _Requirements: 2.1, 2.2, 3.1, 3.2, 4.1, 4.2, 4.3, 6.2, 6.3, 6.4_

- [x] 5. Wire OptionsMenu into MainMenu
  - [x] 5.1 Add Options button handler in `scripts/ui/main_menu.gd`
    - Add `_on_options_button_pressed()` to instance OptionsMenu scene and call `open()`
    - Ensure the OptionsMenu is added as a child of MainMenu and removed/hidden on close
    - _Requirements: 6.1_

  - [x] 5.2 Add OptionsButton node to `scenes/main_menu.tscn` if not already present
    - Connect the button's `pressed` signal to `_on_options_button_pressed`
    - _Requirements: 6.1_

- [x] 6. Checkpoint — Verify full UI integration
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Write unit tests and property-based tests
  - [x] 7.1 Create `tests/test_options_manager.gd` with unit tests
    - Test default settings state (fullscreen, 1920×1080, WASD) when no file exists
    - Test DISPLAY_MODES has 3 entries and RESOLUTIONS has 4 entries
    - Test corrupted file fallback to defaults
    - Test missing file fallback (load_settings returns false)
    - Test SETTINGS_PATH equals "user://settings.cfg"
    - Test rebinding an action to its current key is a no-op
    - _Requirements: 1.1, 2.1, 3.1, 3.4, 5.2, 5.4_

  - [ ]* 7.2 Write property test: Settings serialization round-trip
    - **Property 1: Settings serialization round-trip**
    - Generate random display_mode (0..2), resolution_index (0..3), four random keycodes from valid key pool
    - Save settings then load; assert equivalent state
    - **Validates: Requirements 5.6, 5.1, 5.5, 1.2**

  - [ ]* 7.3 Write property test: Rebind assigns key and updates InputMap
    - **Property 2: Rebind assigns key and updates InputMap**
    - Generate random action from ACTIONS, random keycode from valid key pool
    - Call rebind_key; assert key_bindings[action] == new keycode and InputMap contains matching event
    - **Validates: Requirements 4.3, 4.5**

  - [ ]* 7.4 Write property test: Swap on conflict
    - **Property 3: Swap on conflict**
    - Generate two distinct random actions with random keycodes; rebind first to second's keycode
    - Assert bindings are swapped, not duplicated or lost
    - **Validates: Requirements 4.4**

  - [ ]* 7.5 Write property test: Non-WASD events preserved on rebind
    - **Property 4: Non-WASD events preserved on rebind**
    - Add arrow key events to a random action's InputMap; rebind with new keycode
    - Assert arrow key events still present after rebind
    - **Validates: Requirements 4.6**

  - [ ]* 7.6 Write property test: Snapshot revert round-trip
    - **Property 5: Snapshot revert round-trip**
    - Generate two random valid settings states; snapshot first, apply second, revert to snapshot
    - Assert state matches original snapshot
    - **Validates: Requirements 6.4**

- [x] 8. Register test file in test runner
  - Add `"res://tests/test_options_manager.gd"` to the `_test_files` array in `tests/run_tests.gd`
  - _Requirements: all_

- [x] 9. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- The design uses GDScript throughout, matching the existing codebase
- OptionsManager follows the same autoload pattern as GameManager and SoulEnergyManager
- Property-based tests use the existing PropertyTestRunner with 100 iterations per property
- All tests go in `tests/test_options_manager.gd` and are registered in `tests/run_tests.gd`
