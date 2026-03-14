# Requirements Document

## Introduction

This feature adds a finite multi-level progression system and functional shard stat application to Dark Ascension. Currently the game has a single boss level (skeleton boss) that repeats infinitely. This feature introduces a second level with a wraith boss, a finite game loop (Level 1 → Level 2 → Level 1 → Level 2 → Victory), boss soul rewards, and proper application of shard stats to the necromancer and shadow companions.

## Glossary

- **Level_Manager**: The system that orchestrates boss level lifecycle including wave phase, boss phase, and level transitions.
- **Game_Manager**: The autoload that manages global game state, run-level systems, and scene transitions.
- **Enemy_Spawner**: The system that spawns regular enemies in waves around the player during the wave phase.
- **Boss_Skeleton**: The skeleton boss enemy that appears at the end of Level 1.
- **Boss_Wraith**: The new wraith boss enemy that appears at the end of Level 2.
- **Soul_Drop**: A collectible pickup that spawns when an enemy dies, granting soul energy to the player on collection.
- **Soul_Energy_Manager**: The autoload that tracks the player's soul energy currency during a run.
- **Stat_Bonus_Applier**: The system that reads relic grid bonuses and applies them to the player and shadow companions.
- **Relic_Grid**: The 3x3 grid where shards are placed to generate stat bonuses via adjacency.
- **Shard**: An item with a stat type and base value that can be placed in the Relic_Grid.
- **Player**: The necromancer character controlled by the user.
- **Shadow**: A companion entity (skeleton or wraith) that follows the Player and auto-attacks enemies.
- **Projectile**: A ranged attack entity spawned by the Player or Shadow_Wraith.
- **Victory_Screen**: A UI screen displayed when the player completes all levels in the finite game loop.
- **Post_Level_Screen**: The UI shown after completing a level, offering shop access and level continuation.
- **Run_Cycle**: One complete pass through Level 1 and Level 2 in sequence.
- **Attack_Speed**: A shard stat type that reduces the time between attacks for the Player and Shadows.
- **Cooldown_Reduction**: A shard stat type that reduces the resurrection cooldown timer for dead Shadows.

## Requirements

### Requirement 1: Wraith Boss Enemy

**User Story:** As a player, I want to fight a wraith boss at the end of Level 2, so that the game offers a distinct second-level challenge.

#### Acceptance Criteria

1. THE Boss_Wraith SHALL extend the existing ghost enemy base class with increased health, damage, and scale similar to how Boss_Skeleton extends SkeletonEnemy.
2. WHEN the Boss_Wraith is defeated, THE Boss_Wraith SHALL emit a boss_defeated signal.
3. THE Boss_Wraith SHALL have a soul_value of at least 50 so that defeating the Boss_Wraith awards souls.
4. THE Boss_Wraith SHALL use ranged projectile attacks consistent with the ghost enemy attack pattern.

### Requirement 2: Boss Soul Drops

**User Story:** As a player, I want boss enemies to drop souls when killed, so that I am rewarded for defeating them.

#### Acceptance Criteria

1. WHEN the Boss_Skeleton is defeated, THE Boss_Skeleton SHALL spawn a Soul_Drop with the Boss_Skeleton soul_value at the Boss_Skeleton death position.
2. WHEN the Boss_Wraith is defeated, THE Boss_Wraith SHALL spawn a Soul_Drop with the Boss_Wraith soul_value at the Boss_Wraith death position.
3. WHEN the Player collects a boss Soul_Drop, THE Soul_Energy_Manager SHALL add the soul_value to the player's current soul balance.

### Requirement 3: Level Identification and Sequencing

**User Story:** As a player, I want the game to track which level I am on, so that the correct boss and enemies appear for each level.

#### Acceptance Criteria

1. THE Game_Manager SHALL maintain a current_level variable indicating the active level number (1 or 2).
2. THE Game_Manager SHALL maintain a current_cycle variable indicating the current Run_Cycle number (1 or 2).
3. WHEN a new run starts, THE Game_Manager SHALL set current_level to 1 and current_cycle to 1.
4. THE Level_Manager SHALL read the current_level from the Game_Manager to determine which boss to spawn.

### Requirement 4: Level 1 Configuration

**User Story:** As a player, I want Level 1 to feature the skeleton boss, so that the first level retains its existing gameplay.

#### Acceptance Criteria

1. WHILE current_level equals 1, THE Level_Manager SHALL spawn the Boss_Skeleton during the boss phase.
2. WHILE current_level equals 1, THE Enemy_Spawner SHALL spawn skeleton and ghost enemies during the wave phase using the existing spawn configuration.

### Requirement 5: Level 2 Configuration

**User Story:** As a player, I want Level 2 to feature the wraith boss, so that the second level provides a different challenge.

#### Acceptance Criteria

1. WHILE current_level equals 2, THE Level_Manager SHALL spawn the Boss_Wraith during the boss phase.
2. WHILE current_level equals 2, THE Enemy_Spawner SHALL spawn skeleton and ghost enemies during the wave phase.

### Requirement 6: Finite Game Loop Progression

**User Story:** As a player, I want the game to progress through a finite sequence of levels and then show a victory screen, so that the game has a clear ending.

#### Acceptance Criteria

1. WHEN Level 1 of Run_Cycle 1 is completed, THE Game_Manager SHALL advance current_level to 2 and keep current_cycle at 1.
2. WHEN Level 2 of Run_Cycle 1 is completed, THE Game_Manager SHALL advance current_cycle to 2 and reset current_level to 1.
3. WHEN Level 1 of Run_Cycle 2 is completed, THE Game_Manager SHALL advance current_level to 2 and keep current_cycle at 2.
4. WHEN Level 2 of Run_Cycle 2 is completed, THE Game_Manager SHALL trigger the Victory_Screen display.
5. THE Game_Manager SHALL persist current_level and current_cycle across scene transitions using the run state save/load mechanism.

### Requirement 7: Victory Screen

**User Story:** As a player, I want to see a victory screen when I complete all levels, so that I know I have beaten the game.

#### Acceptance Criteria

1. WHEN the final level (Level 2, Run_Cycle 2) is completed, THE Level_Manager SHALL display the Victory_Screen instead of the standard Post_Level_Screen.
2. THE Victory_Screen SHALL display a congratulatory title message.
3. THE Victory_Screen SHALL display the total soul energy earned during the run.
4. THE Victory_Screen SHALL provide a button to return to the main menu.
5. THE Victory_Screen SHALL provide a button to start a new run.

### Requirement 8: Post-Level Screen Level Awareness

**User Story:** As a player, I want the post-level screen to correctly transition me to the next level in the sequence, so that progression feels seamless.

#### Acceptance Criteria

1. WHEN the player presses "Next Level" on the Post_Level_Screen, THE Game_Manager SHALL advance to the next level in the sequence before loading the boss level scene.
2. WHEN the player presses "Go to Shop" after a level, THE Game_Manager SHALL preserve the current level and cycle state in the saved run state.
3. WHEN the player presses "Next Level" from the shop, THE Game_Manager SHALL load the boss level scene with the correct current_level and current_cycle.

### Requirement 9: Attack Speed Stat Application

**User Story:** As a player, I want the Attack_Speed shard stat to reduce attack intervals for the necromancer and shadows, so that attack speed shards have a visible gameplay effect.

#### Acceptance Criteria

1. WHEN the Stat_Bonus_Applier applies bonuses, THE Stat_Bonus_Applier SHALL reduce the Player attack_cooldown by the Attack_Speed percentage from the Relic_Grid, clamped to a minimum of 10% of the base cooldown.
2. WHEN the Stat_Bonus_Applier applies bonuses, THE Stat_Bonus_Applier SHALL reduce each Shadow attack_cooldown by the Attack_Speed percentage from the Relic_Grid, clamped to a minimum of 10% of the base cooldown.
3. THE Stat_Bonus_Applier SHALL treat Attack_Speed and Cooldown_Reduction as separate stats: Attack_Speed reduces attack intervals, Cooldown_Reduction reduces resurrection cooldowns.

### Requirement 10: Cooldown Reduction Stat Application to Resurrection

**User Story:** As a player, I want the Cooldown_Reduction shard stat to reduce shadow resurrection cooldowns, so that dead shadows can be revived faster.

#### Acceptance Criteria

1. WHEN the Stat_Bonus_Applier applies bonuses, THE Stat_Bonus_Applier SHALL calculate the effective resurrection cooldown for each shadow type by reducing the base resurrection cooldown by the Cooldown_Reduction percentage from the Relic_Grid.
2. THE Shadow_Resurrection_System SHALL use the effective resurrection cooldowns provided by the Stat_Bonus_Applier instead of the hardcoded base values.
3. THE effective resurrection cooldown SHALL be clamped to a minimum of 10% of the base resurrection cooldown to prevent zero or negative cooldowns.

### Requirement 11: Stat Bonus Registration on Level Load

**User Story:** As a player, I want shard stat bonuses to be applied when a level loads, so that purchased shards take effect immediately.

#### Acceptance Criteria

1. WHEN a boss level scene is loaded, THE Player SHALL register with the Stat_Bonus_Applier during initialization.
2. WHEN shadows are spawned, each Shadow SHALL register with the Stat_Bonus_Applier during initialization.
3. WHEN all entities are registered, THE Stat_Bonus_Applier SHALL call apply_bonuses to apply the current Relic_Grid stat values to the Player and all Shadows.
4. WHEN the run state is restored from a scene transition, THE Stat_Bonus_Applier SHALL reapply bonuses after restoring the Relic_Grid state.

### Requirement 12: Projectile Damage Amplification

**User Story:** As a player, I want the Damage_Amp shard stat to increase projectile damage, so that damage shards have a visible gameplay effect.

#### Acceptance Criteria

1. WHEN a Projectile spawned by the Player hits an enemy, THE Projectile SHALL deal base damage multiplied by (1 + damage_amp / 100), where damage_amp is the current Damage_Amp value from the Stat_Bonus_Applier.
2. WHEN a Projectile spawned by a Shadow hits an enemy, THE Projectile SHALL deal the Shadow attack_damage (already modified by the Stat_Bonus_Applier).
3. THE Projectile SHALL read the damage_amp value from the Stat_Bonus_Applier at the time of impact rather than at spawn time.

### Requirement 13: Soul Bonus Stat Application

**User Story:** As a player, I want the Soul_Bonus shard stat to increase soul drops, so that soul bonus shards have a visible gameplay effect.

#### Acceptance Criteria

1. WHEN a Soul_Drop is collected by the Player, THE Soul_Energy_Manager SHALL add the soul_value multiplied by (1 + soul_bonus / 100), where soul_bonus is the current Soul_Bonus value from the Stat_Bonus_Applier.
2. THE Soul_Bonus calculation SHALL round the final soul amount to the nearest integer.

### Requirement 14: Run Reset on New Game

**User Story:** As a player, I want all progression state to reset when I start a new run, so that each run begins fresh.

#### Acceptance Criteria

1. WHEN a new run is started, THE Game_Manager SHALL reset current_level to 1 and current_cycle to 1.
2. WHEN a new run is started, THE Game_Manager SHALL reset soul energy, relic grid, and shard inventory via the existing start_new_run method.
3. WHEN a new run is started, THE Level_Manager SHALL clear the saved run state.
