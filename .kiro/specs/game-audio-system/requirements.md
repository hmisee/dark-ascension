# Requirements Document

## Introduction

Dark Ascension currently has no audio. This feature adds a complete audio system covering background music and sound effects. The system uses Godot's AudioServer bus architecture with a dedicated autoload (AudioManager) to manage playback. Three background music tracks cover the game's distinct contexts (menus, minion waves, boss encounters), and sound effects provide feedback for combat events (damage taken, attacks, enemy deaths, shadow deaths). Volume controls are integrated into the existing OptionsManager and options menu. All audio assets are expected to be AI-generated and placed in the existing `assets/audio/` directory structure.

## Glossary

- **AudioManager**: A GDScript autoload node responsible for playing, stopping, and crossfading background music and triggering sound effects through Godot's AudioStreamPlayer nodes.
- **Audio_Bus**: A channel in Godot's AudioServer used to group and control volume for a category of sounds (e.g. Master, Music, SFX).
- **BGM**: Background music — a looping audio track that plays continuously during a game context.
- **SFX**: Sound effect — a short, non-looping audio clip triggered by a game event.
- **Crossfade**: A transition where one BGM track fades out while another fades in over a defined duration.
- **Player**: The necromancer character controlled by the user (scripts/entities/player.gd).
- **Shadow**: An allied companion entity that follows and fights alongside the Player (scripts/entities/shadow.gd).
- **Enemy**: A hostile entity that attacks the Player and Shadows (scripts/entities/enemy.gd).
- **Boss**: A stronger Enemy variant that appears during the boss phase of a level (BossSkeleton, BossWraith).
- **LevelManager**: The system that orchestrates level phases — wave phase (minions) and boss phase (scripts/systems/level_manager.gd).
- **OptionsManager**: The existing autoload that manages display and input settings, to be extended with audio volume settings (scripts/autoloads/options_manager.gd).
- **Wave_Phase**: The first phase of a level where regular enemies spawn for a timed duration.
- **Boss_Phase**: The second phase of a level where the boss spawns after the wave timer expires.

## Requirements

### Requirement 1: Audio Bus Setup

**User Story:** As a developer, I want dedicated audio buses for music and sound effects, so that each category can be volume-controlled independently.

#### Acceptance Criteria

1. THE Audio_Bus layout SHALL define three buses: "Master", "Music", and "SFX".
2. THE "Music" Audio_Bus SHALL route its output to the "Master" Audio_Bus.
3. THE "SFX" Audio_Bus SHALL route its output to the "Master" Audio_Bus.
4. THE AudioManager SHALL load the audio bus layout on startup.

### Requirement 2: AudioManager Autoload

**User Story:** As a developer, I want a centralized audio manager autoload, so that any script can request music or sound effect playback without managing audio nodes directly.

#### Acceptance Criteria

1. THE AudioManager SHALL be registered as a Godot autoload in project.godot.
2. THE AudioManager SHALL expose a `play_bgm(track_name: String)` method that starts the specified BGM track on the "Music" Audio_Bus.
3. THE AudioManager SHALL expose a `play_sfx(sfx_name: String)` method that plays the specified SFX clip on the "SFX" Audio_Bus.
4. THE AudioManager SHALL preload all audio resources at initialization to avoid runtime loading delays.
5. WHEN `play_bgm` is called with the name of the already-playing BGM track, THE AudioManager SHALL continue playback without restarting the track.

### Requirement 3: Background Music — Menu Track

**User Story:** As a player, I want calm background music in menus and the shop, so that the non-combat screens feel atmospheric.

#### Acceptance Criteria

1. WHEN the main menu scene loads, THE AudioManager SHALL play the "menu" BGM track.
2. WHEN the options menu scene loads, THE AudioManager SHALL continue playing the "menu" BGM track.
3. WHEN the shop scene loads, THE AudioManager SHALL play the "menu" BGM track.
4. THE "menu" BGM track SHALL loop continuously until a different BGM track is requested.

### Requirement 4: Background Music — Minion Wave Track

**User Story:** As a player, I want action-oriented music during the minion wave phase, so that combat against regular enemies feels engaging.

#### Acceptance Criteria

1. WHEN the LevelManager enters the Wave_Phase, THE AudioManager SHALL play the "wave" BGM track.
2. THE "wave" BGM track SHALL loop continuously until a different BGM track is requested.

### Requirement 5: Background Music — Boss Encounter Track

**User Story:** As a player, I want intense music during boss encounters, so that boss fights feel climactic.

#### Acceptance Criteria

1. WHEN the LevelManager enters the Boss_Phase, THE AudioManager SHALL play the "boss" BGM track.
2. THE "boss" BGM track SHALL loop continuously until a different BGM track is requested.

### Requirement 6: BGM Crossfade Transitions

**User Story:** As a player, I want smooth transitions between music tracks, so that track changes do not feel jarring.

#### Acceptance Criteria

1. WHEN a new BGM track is requested while another BGM track is playing, THE AudioManager SHALL crossfade from the current track to the new track over 1.5 seconds.
2. WHILE a crossfade is in progress, THE AudioManager SHALL linearly decrease the volume of the outgoing track from its current level to silence.
3. WHILE a crossfade is in progress, THE AudioManager SHALL linearly increase the volume of the incoming track from silence to the configured Music bus level.
4. IF a new BGM track is requested during an in-progress crossfade, THEN THE AudioManager SHALL cancel the current crossfade and begin a new crossfade from the current audio state.

### Requirement 7: Player Damage Sound Effect

**User Story:** As a player, I want to hear a sound when my character takes damage, so that I get immediate audio feedback about incoming hits.

#### Acceptance Criteria

1. WHEN the Player `take_damage` method is called and the Player current_health is greater than zero, THE AudioManager SHALL play the "player_hit" SFX.
2. WHEN the Player `take_damage` method is called and the Player current_health reaches zero or below, THE AudioManager SHALL play the "player_death" SFX.

### Requirement 8: Player Attack Sound Effect

**User Story:** As a player, I want to hear a sound when my character fires a projectile, so that attacks feel impactful.

#### Acceptance Criteria

1. WHEN the Player `spawn_projectile` method executes, THE AudioManager SHALL play the "player_attack" SFX.

### Requirement 9: Enemy Damage and Death Sound Effects

**User Story:** As a player, I want audio feedback when enemies are hit or killed, so that combat feels responsive.

#### Acceptance Criteria

1. WHEN an Enemy `take_damage` method is called and the Enemy current_health is greater than zero, THE AudioManager SHALL play the "enemy_hit" SFX.
2. WHEN an Enemy `die` method executes, THE AudioManager SHALL play the "enemy_death" SFX.

### Requirement 10: Shadow Death Sound Effect

**User Story:** As a player, I want to hear when one of my shadow companions falls, so that I am aware of the loss during combat.

#### Acceptance Criteria

1. WHEN a Shadow `die` method executes, THE AudioManager SHALL play the "shadow_death" SFX.

### Requirement 11: Boss Defeat Sound Effect

**User Story:** As a player, I want a distinct sound when a boss is defeated, so that the victory moment feels rewarding.

#### Acceptance Criteria

1. WHEN a Boss `die` method executes, THE AudioManager SHALL play the "boss_defeat" SFX.

### Requirement 12: SFX Polyphony

**User Story:** As a player, I want multiple sound effects to play simultaneously without cutting each other off, so that overlapping combat events all produce audio feedback.

#### Acceptance Criteria

1. THE AudioManager SHALL support playing up to 8 concurrent SFX clips.
2. WHEN a new SFX is requested and all 8 SFX channels are in use, THE AudioManager SHALL reuse the channel whose playback is closest to completion.

### Requirement 13: Volume Controls in Options Menu

**User Story:** As a player, I want sliders for Master, Music, and SFX volume in the options menu, so that I can adjust audio levels to my preference.

#### Acceptance Criteria

1. THE options menu SHALL display a volume slider for the "Master" Audio_Bus with a range of 0 to 100.
2. THE options menu SHALL display a volume slider for the "Music" Audio_Bus with a range of 0 to 100.
3. THE options menu SHALL display a volume slider for the "SFX" Audio_Bus with a range of 0 to 100.
4. WHEN a volume slider value changes, THE OptionsManager SHALL set the corresponding Audio_Bus volume in the AudioServer immediately.
5. WHEN the volume slider is set to 0, THE OptionsManager SHALL mute the corresponding Audio_Bus.
6. THE OptionsManager SHALL persist volume settings to the settings file alongside existing display and input settings.
7. WHEN the game starts, THE OptionsManager SHALL restore saved volume settings and apply them to the AudioServer.

### Requirement 14: Post-Combat Music Transition

**User Story:** As a player, I want the music to return to the menu track after a level ends, so that victory and failure screens feel distinct from combat.

#### Acceptance Criteria

1. WHEN the LevelManager enters the COMPLETE state, THE AudioManager SHALL transition to the "menu" BGM track.
2. WHEN the LevelManager enters the FAILED state, THE AudioManager SHALL transition to the "menu" BGM track.

### Requirement 15: Audio Asset File Organization

**User Story:** As a developer, I want audio files organized in the existing asset directory structure, so that the project stays maintainable.

#### Acceptance Criteria

1. THE BGM audio files SHALL be stored in the `assets/audio/music/` directory.
2. THE SFX audio files SHALL be stored in the `assets/audio/sfx/` directory.
3. THE AudioManager SHALL reference audio files using `res://assets/audio/` resource paths.
