# Design Document: Game Audio System

## Overview

This design adds a complete audio system to Dark Ascension, covering background music (BGM) with crossfade transitions and sound effects (SFX) with polyphonic playback. The system is built around a single `AudioManager` autoload that centralizes all audio playback, using Godot's `AudioServer` bus architecture for independent volume control of music and effects.

The design integrates with the existing codebase by:
- Adding `AudioManager.play_bgm()` calls in scene scripts (`main_menu.gd`, `shop_scene.gd`) and `LevelManager` phase transitions.
- Adding `AudioManager.play_sfx()` calls in entity scripts (`player.gd`, `enemy.gd`, `shadow.gd`, boss scripts).
- Extending `OptionsManager` with volume state and persistence, and adding slider UI to `options_menu.gd`.
- Creating a `default_bus_layout.tres` resource with Master, Music, and SFX buses.

All audio assets are AI-generated `.ogg` files placed under `assets/audio/music/` and `assets/audio/sfx/`.

## Architecture

```mermaid
graph TD
    subgraph Autoloads
        AM[AudioManager]
        OM[OptionsManager]
    end

    subgraph AudioServer
        MASTER[Master Bus]
        MUSIC[Music Bus] --> MASTER
        SFX_BUS[SFX Bus] --> MASTER
    end

    subgraph Scenes
        MM[main_menu.gd]
        SS[shop_scene.gd]
        LM[LevelManager]
        OPT[options_menu.gd]
    end

    subgraph Entities
        PL[player.gd]
        EN[enemy.gd]
        SH[shadow.gd]
        BS[boss_skeleton.gd]
        BW[boss_wraith.gd]
    end

    MM -->|play_bgm "menu"| AM
    SS -->|play_bgm "menu"| AM
    LM -->|play_bgm "wave"/"boss"/"menu"| AM
    OPT -->|set volume| OM
    OM -->|AudioServer.set_bus_volume_db| AudioServer

    PL -->|play_sfx| AM
    EN -->|play_sfx| AM
    SH -->|play_sfx| AM
    BS -->|play_sfx| AM
    BW -->|play_sfx| AM

    AM -->|BGM players| MUSIC
    AM -->|SFX pool| SFX_BUS
```

The AudioManager owns two `AudioStreamPlayer` nodes for BGM (enabling crossfade between them) and a pool of 8 `AudioStreamPlayer` nodes for concurrent SFX. All BGM players route to the "Music" bus; all SFX players route to the "SFX" bus.

### Key Design Decisions

1. **Autoload singleton** — Matches the existing pattern (`GameManager`, `SoulEnergyManager`, `OptionsManager`). Any script can call `AudioManager.play_bgm()` or `AudioManager.play_sfx()` without node references.

2. **Dual BGM players for crossfade** — Two `AudioStreamPlayer` nodes alternate roles (active/fading-out). A `Tween` handles the volume interpolation over 1.5 seconds. If a new crossfade is requested mid-transition, the current tween is killed and a new one starts from the current volume state.

3. **SFX object pool** — 8 pre-created `AudioStreamPlayer` nodes avoid runtime allocation. When all are busy, the one closest to finishing is reused. This is simpler and more performant than dynamic instantiation.

4. **Preloaded resources** — All audio streams are loaded in `_ready()` into dictionaries keyed by track/sfx name. This avoids frame hitches from disk I/O during gameplay.

5. **Volume via OptionsManager** — Volume state lives in `OptionsManager` alongside display/input settings, using the same `ConfigFile` persistence. The AudioManager reads bus volumes from `AudioServer` directly, so `OptionsManager` is the single source of truth for volume settings.

## Components and Interfaces

### AudioManager (scripts/autoloads/audio_manager.gd)

```gdscript
extends Node

# --- BGM ---
func play_bgm(track_name: String) -> void
    ## Starts the named BGM track. If already playing, no-op.
    ## If a different track is playing, crossfades over 1.5s.

func stop_bgm() -> void
    ## Stops all BGM playback immediately.

func get_current_bgm() -> String
    ## Returns the name of the currently playing BGM track, or "".

# --- SFX ---
func play_sfx(sfx_name: String) -> void
    ## Plays the named SFX clip on the next available SFX channel.
    ## If all 8 channels are busy, reuses the one closest to completion.

# --- Internal ---
var _bgm_tracks: Dictionary       # { "menu": AudioStream, "wave": AudioStream, "boss": AudioStream }
var _sfx_clips: Dictionary        # { "player_hit": AudioStream, ... }
var _bgm_players: Array[AudioStreamPlayer]  # 2 players for crossfade
var _sfx_players: Array[AudioStreamPlayer]  # 8 players for polyphony
var _current_bgm: String = ""
var _active_bgm_index: int = 0    # Index into _bgm_players (0 or 1)
var _crossfade_tween: Tween = null
const CROSSFADE_DURATION: float = 1.5
const SFX_POOL_SIZE: int = 8
```

### OptionsManager Extensions (scripts/autoloads/options_manager.gd)

New state variables and methods added to the existing OptionsManager:

```gdscript
# --- New State ---
var master_volume: int = 100    # 0-100
var music_volume: int = 100     # 0-100
var sfx_volume: int = 100       # 0-100

# --- New Methods ---
func apply_volume(bus_name: String, value: int) -> void
    ## Converts 0-100 integer to dB, sets AudioServer bus volume.
    ## Mutes the bus when value == 0.

func _volume_to_db(value: int) -> float
    ## Converts linear 0-100 to dB scale using linear_to_db().
```

Persistence: `save_settings()` and `load_settings()` are extended to include `[audio]` section with `master_volume`, `music_volume`, `sfx_volume` keys. `reset_to_defaults()` sets all three to 100.

### Options Menu UI Extensions (scripts/ui/options_menu.gd)

Three `HSlider` nodes are added to the options menu scene for Master, Music, and SFX volume. Each slider:
- Range: 0 to 100, step 1
- Reads initial value from `OptionsManager` on open
- Calls `OptionsManager.apply_volume()` on `value_changed` for live preview
- Persists on Apply, reverts on Cancel (using the existing snapshot pattern)

### Audio Bus Layout (default_bus_layout.tres)

A Godot `AudioBusLayout` resource defining:
- Bus 0: "Master" (default output)
- Bus 1: "Music" → sends to "Master"
- Bus 2: "SFX" → sends to "Master"

Referenced in `project.godot` via `[audio] bus_layout="res://default_bus_layout.tres"`.

### Autoload Helper Extension (scripts/autoloads/autoload_helper.gd)

```gdscript
static func audio_manager() -> Node:
    return Engine.get_main_loop().root.get_node("AudioManager")
```

### Integration Points

| Caller | Method | Trigger |
|---|---|---|
| `main_menu.gd` `_ready()` | `AudioManager.play_bgm("menu")` | Scene loads |
| `shop_scene.gd` `_ready()` | `AudioManager.play_bgm("menu")` | Scene loads |
| `level_manager.gd` `start_level()` | `AudioManager.play_bgm("wave")` | Wave phase begins |
| `level_manager.gd` `_start_boss_phase()` | `AudioManager.play_bgm("boss")` | Boss phase begins |
| `level_manager.gd` `_on_level_complete()` | `AudioManager.play_bgm("menu")` | Level complete |
| `level_manager.gd` `_on_level_failed()` | `AudioManager.play_bgm("menu")` | Level failed |
| `player.gd` `take_damage()` | `AudioManager.play_sfx("player_hit")` or `("player_death")` | Health check |
| `player.gd` `spawn_projectile()` | `AudioManager.play_sfx("player_attack")` | Projectile fired |
| `enemy.gd` `take_damage()` | `AudioManager.play_sfx("enemy_hit")` | Enemy hit (alive) |
| `enemy.gd` `die()` | `AudioManager.play_sfx("enemy_death")` | Enemy dies |
| `shadow.gd` `die()` | `AudioManager.play_sfx("shadow_death")` | Shadow dies |
| `boss_skeleton.gd` `die()` | `AudioManager.play_sfx("boss_defeat")` | Boss dies |
| `boss_wraith.gd` `die()` | `AudioManager.play_sfx("boss_defeat")` | Boss dies |

## Data Models

### Audio Resource Maps

BGM tracks (preloaded in `AudioManager._ready()`):

| Key | File Path |
|---|---|
| `"menu"` | `res://assets/audio/music/menu.ogg` |
| `"wave"` | `res://assets/audio/music/wave.ogg` |
| `"boss"` | `res://assets/audio/music/boss.ogg` |

SFX clips (preloaded in `AudioManager._ready()`):

| Key | File Path |
|---|---|
| `"player_hit"` | `res://assets/audio/sfx/player_hit.ogg` |
| `"player_death"` | `res://assets/audio/sfx/player_death.ogg` |
| `"player_attack"` | `res://assets/audio/sfx/player_attack.ogg` |
| `"enemy_hit"` | `res://assets/audio/sfx/enemy_hit.ogg` |
| `"enemy_death"` | `res://assets/audio/sfx/enemy_death.ogg` |
| `"shadow_death"` | `res://assets/audio/sfx/shadow_death.ogg` |
| `"boss_defeat"` | `res://assets/audio/sfx/boss_defeat.ogg` |

### Volume Settings (ConfigFile format)

```ini
[audio]
master_volume=100
music_volume=100
sfx_volume=100
```

Stored in `user://settings.cfg` alongside existing `[display]` and `[input]` sections.

### AudioManager Internal State

```
_current_bgm: String          — Name of the active BGM track ("" if none)
_active_bgm_index: int         — Which of the 2 BGM players is currently active (0 or 1)
_crossfade_tween: Tween        — Active crossfade tween (null if no crossfade in progress)
_bgm_tracks: Dictionary        — Preloaded BGM AudioStream resources
_sfx_clips: Dictionary         — Preloaded SFX AudioStream resources
_bgm_players: Array            — 2 AudioStreamPlayer nodes (Music bus)
_sfx_players: Array            — 8 AudioStreamPlayer nodes (SFX bus)
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: BGM plays on Music bus

*For any* valid BGM track name, calling `play_bgm(track_name)` should result in an `AudioStreamPlayer` playing on the "Music" bus, and no BGM audio should ever play on any other bus.

**Validates: Requirements 2.2**

### Property 2: SFX plays on SFX bus

*For any* valid SFX clip name, calling `play_sfx(sfx_name)` should result in an `AudioStreamPlayer` playing on the "SFX" bus, and no SFX audio should ever play on any other bus.

**Validates: Requirements 2.3**

### Property 3: BGM idempotence

*For any* BGM track that is currently playing, calling `play_bgm` with the same track name should not restart playback — the playback position should remain unchanged and no crossfade should be initiated.

**Validates: Requirements 2.5, 3.2**

### Property 4: Crossfade between different BGM tracks

*For any* pair of different valid BGM track names (A, B), if track A is playing and `play_bgm(B)` is called, then after 1.5 seconds track B should be the active track at full volume and track A should be silent.

**Validates: Requirements 6.1**

### Property 5: Crossfade interruption resolves to last requested track

*For any* sequence of 3 or more different BGM track requests issued in rapid succession (faster than the 1.5s crossfade duration), the final audio state should be the last requested track playing at full volume with all other tracks silent.

**Validates: Requirements 6.4**

### Property 6: Player damage SFX selection

*For any* player with `current_health > 0` and *for any* damage amount, calling `take_damage(amount)` should play "player_hit" SFX if `current_health - amount > 0`, or "player_death" SFX if `current_health - amount <= 0`.

**Validates: Requirements 7.1, 7.2**

### Property 7: Enemy damage SFX on non-lethal hit

*For any* enemy with `current_health > 0` and *for any* damage amount where `current_health - amount > 0`, calling `take_damage(amount)` should play the "enemy_hit" SFX.

**Validates: Requirements 9.1**

### Property 8: SFX channel allocation and reuse

*For any* sequence of SFX play requests, the first 8 concurrent requests should each use a distinct channel. When all 8 channels are in use and a 9th request arrives, the channel whose playback is closest to completion should be reused.

**Validates: Requirements 12.1, 12.2**

### Property 9: Volume application to AudioServer

*For any* bus name in {"Master", "Music", "SFX"} and *for any* volume value in the range [0, 100], calling `apply_volume(bus_name, value)` should set the corresponding AudioServer bus volume to `linear_to_db(value / 100.0)`, and when value is 0 the bus should be muted.

**Validates: Requirements 13.4, 13.5**

### Property 10: Volume settings persistence round-trip

*For any* combination of master_volume, music_volume, and sfx_volume values in [0, 100], saving settings and then loading them should restore the exact same volume values and apply them to the AudioServer.

**Validates: Requirements 13.6, 13.7**

## Error Handling

| Scenario | Handling |
|---|---|
| `play_bgm` called with unknown track name | Log a warning via `push_warning()`, do not crash. No audio change. |
| `play_sfx` called with unknown SFX name | Log a warning via `push_warning()`, do not crash. No audio change. |
| Audio file missing from disk (preload fails) | `AudioManager._ready()` logs a warning for each missing resource. The track/clip key is omitted from the dictionary, so subsequent play calls hit the "unknown name" path above. |
| `AudioServer` bus not found by name | `AudioServer.get_bus_index()` returns -1. `apply_volume` should check for this and log a warning instead of crashing. |
| Volume value out of range (< 0 or > 100) | `apply_volume` clamps the value to [0, 100] before applying. |
| `play_bgm` called before `_ready()` completes | Resources not yet loaded. The method should early-return if `_bgm_tracks` is empty. |
| Crossfade tween killed externally | The `_crossfade_tween` reference becomes invalid. Check `is_instance_valid()` before killing. |
| Settings file missing audio section | `load_settings()` uses `get_value()` with defaults (100 for each volume), so missing keys gracefully fall back. |

## Testing Strategy

### Testing Framework

The project uses **GdUnit4** for unit testing with the existing `GdUnitTestSuite` base class and console runner (`tests/run_tests.gd`). Property-based tests use the existing `PropertyTestRunner` helper class (`tests/helpers/property_test_runner.gd`).

### Dual Testing Approach

**Unit tests** verify specific examples, integration points, and edge cases:
- Audio bus layout has correct bus count and names (Req 1.1-1.3)
- AudioManager preloads all expected resource keys (Req 2.4)
- Scene integration points call correct BGM/SFX methods (Req 3.1, 3.3, 4.1, 5.1, 8.1, 9.2, 10.1, 11.1, 14.1, 14.2)
- BGM tracks are configured to loop (Req 3.4, 4.2, 5.2)
- Options menu sliders have correct range (Req 13.1-13.3)
- Resource paths use `res://assets/audio/` prefix (Req 15.3)
- Error handling for unknown track/SFX names

**Property-based tests** verify universal properties across randomized inputs:
- Each correctness property (1-10) is implemented as a single property-based test
- Minimum 100 iterations per property test using `PropertyTestRunner`
- Each test is tagged with a comment: `# Feature: game-audio-system, Property {N}: {title}`

### Test Files

- `tests/test_audio_manager.gd` — Unit and property tests for AudioManager (BGM, SFX, crossfade, channel allocation)
- `tests/test_audio_options.gd` — Unit and property tests for OptionsManager volume extensions (apply_volume, persistence round-trip)

### Property Test Configuration

- Library: `PropertyTestRunner` (existing in `tests/helpers/property_test_runner.gd`)
- Iterations: 100 per property
- Tag format: `# Feature: game-audio-system, Property {number}: {property_title}`
- Each correctness property maps to exactly one property-based test function
