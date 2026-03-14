# Requirements Document

## Introduction

The boss level system introduces a structured level with a survival timer and a boss enemy to Dark Ascension. Currently the game has an open-ended arena test scene with infinite enemy spawning but no win/loss conditions, no boss enemies, and no level progression. This feature adds a boss level with a 20-second survival timer, a boss skeleton enemy (larger and tougher than the regular skeleton), and the level-completion hooks needed to enable the shard shop and relic grid systems that already exist but cannot be tested without a level boundary.

## Glossary

- **Level_Manager**: The script that controls level flow, including the survival timer, win/loss conditions, and transitions to post-level screens.
- **Boss_Skeleton**: A larger, higher-health variant of the SkeletonEnemy that serves as the level boss.
- **Survival_Timer**: A countdown timer that defines how long the player must survive to complete the level.
- **Enemy_Spawner**: The existing system that spawns skeleton and ghost enemies around the player during a level.
- **Shard_Shop**: The existing between-levels shop that offers random shards for purchase with soul energy.
- **Relic_Grid**: The existing 3x3 grid where the player places shards to receive stat bonuses.
- **Player**: The player-controlled necromancer character.
- **HUD**: The in-game heads-up display showing level status information.
- **Post_Level_Screen**: The UI shown after a level ends, providing access to the shard shop and relic grid before the next level.

## Requirements

### Requirement 1: Survival Timer

**User Story:** As a player, I want a visible countdown timer during the level, so that I know how long I must survive to win.

#### Acceptance Criteria

1. WHEN a boss level starts, THE Level_Manager SHALL initialize the Survival_Timer to 20 seconds and begin counting down.
2. WHILE the Survival_Timer is active, THE HUD SHALL display the remaining time in seconds, updated every frame.
3. WHEN the Survival_Timer reaches zero, THE Level_Manager SHALL trigger the level-complete state.
4. IF the Player dies before the Survival_Timer reaches zero, THEN THE Level_Manager SHALL trigger the level-failed state.

### Requirement 2: Boss Skeleton Enemy

**User Story:** As a player, I want to face a boss skeleton that is visually larger and harder to kill, so that the level has a challenging focal enemy.

#### Acceptance Criteria

1. THE Boss_Skeleton SHALL extend the existing SkeletonEnemy class.
2. THE Boss_Skeleton SHALL have a scale of 2.0 (twice the size of a regular skeleton).
3. THE Boss_Skeleton SHALL have 200 max health (compared to 30 for a regular skeleton).
4. THE Boss_Skeleton SHALL deal 20 contact damage (compared to 8 for a regular skeleton).
5. THE Boss_Skeleton SHALL have a move speed of 70 (compared to 100 for a regular skeleton, slower due to size).
6. THE Boss_Skeleton SHALL award 50 soul energy on death (compared to 10 for a regular skeleton).
7. WHEN the Boss_Skeleton dies, THE Boss_Skeleton SHALL emit a signal indicating the boss has been defeated.

### Requirement 3: Boss Level Scene

**User Story:** As a player, I want a dedicated boss level scene with only the boss enemy, so that I have a focused one-on-one combat encounter.

#### Acceptance Criteria

1. THE Level_Manager SHALL spawn the Boss_Skeleton at a fixed distance of 400 pixels from the Player when the level starts.
2. THE Level_Manager SHALL NOT activate the Enemy_Spawner during the boss level.
3. WHEN the level starts, THE Level_Manager SHALL spawn the Player at the center of the arena.
4. THE Level_Manager SHALL include the Player and the Boss_Skeleton as part of the boss level scene.
5. THE Level_Manager SHALL support a configurable flag to enable the Enemy_Spawner during boss levels in future updates.

### Requirement 4: Level Completion Flow

**User Story:** As a player, I want to see a results screen after completing a level, so that I can spend soul energy in the shard shop and manage my relic grid before continuing.

#### Acceptance Criteria

1. WHEN the level-complete state is triggered, THE Level_Manager SHALL remove the Boss_Skeleton if it is still alive and clean up the arena.
2. WHEN the level-complete state is triggered, THE Level_Manager SHALL display the Post_Level_Screen.
3. THE Post_Level_Screen SHALL show the total soul energy earned during the level.
4. THE Post_Level_Screen SHALL provide access to the Shard_Shop with a freshly generated set of shard offers.
5. THE Post_Level_Screen SHALL provide access to the Relic_Grid for placing and rearranging shards.
6. WHEN the level-complete state is triggered, THE Level_Manager SHALL call award_relic on the GameManager to unlock the Relic_Grid if it is not already unlocked.
7. THE Post_Level_Screen SHALL include a button to proceed to the next level or return to the main menu.

### Requirement 5: Level Failure Flow

**User Story:** As a player, I want a clear failure screen when I die, so that I know the run ended and can choose to retry or return to the menu.

#### Acceptance Criteria

1. WHEN the level-failed state is triggered, THE Level_Manager SHALL remove the Boss_Skeleton and clean up the arena.
2. WHEN the level-failed state is triggered, THE Level_Manager SHALL display a failure screen with the text "You Died".
3. THE failure screen SHALL include a button to retry the level.
4. THE failure screen SHALL include a button to return to the main menu.
5. WHEN the retry button is pressed, THE Level_Manager SHALL reset the level by calling start_new_run on the GameManager and reloading the boss level scene.

### Requirement 6: HUD Timer Display

**User Story:** As a player, I want to see the survival timer prominently on screen, so that I can make tactical decisions based on remaining time.

#### Acceptance Criteria

1. THE HUD SHALL display the Survival_Timer value at the top center of the screen.
2. THE HUD SHALL format the timer as whole seconds (rounded up) when above 10 seconds.
3. WHEN the Survival_Timer is at or below 10 seconds, THE HUD SHALL display the timer with one decimal place.
4. WHEN the Survival_Timer is at or below 5 seconds, THE HUD SHALL change the timer text color to red.

### Requirement 7: Run State Persistence Across Levels

**User Story:** As a player, I want my soul energy, shard inventory, and relic grid state to carry over between levels, so that my progression within a run is preserved.

#### Acceptance Criteria

1. WHEN the player proceeds from the Post_Level_Screen to the next level, THE Level_Manager SHALL call save_run_state on the GameManager before transitioning.
2. WHEN a new level loads, THE Level_Manager SHALL call load_run_state on the GameManager to restore the previous level state.
3. THE Level_Manager SHALL preserve soul energy, relic grid placement, and shard inventory across level transitions.
