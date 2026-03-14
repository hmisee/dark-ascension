# Requirements Document: Soul & Relic System

## Introduction

The Soul & Relic System introduces a soul energy economy, shadow resurrection mechanics, and a relic-based shard placement system to Dark Ascension. Souls are earned by killing enemies and spent on resurrecting fallen shadow companions or purchasing items. The Relic is a 3x3 grid where the player places stat-boosting shards with cardinal adjacency bonuses, creating a strategic placement puzzle. This is the v1 scope covering soul earning/spending, shadow resurrection with cooldowns and weakened revival, and ~8-10 shard types with adjacency mechanics.

## Glossary

- **Soul_Energy_Manager**: The autoload system responsible for tracking, awarding, and spending soul energy across a run.
- **Shadow**: A companion entity (ShadowSkeleton or ShadowWraith) that follows the player and auto-attacks enemies. Defined in `shadow.gd`.
- **Shadow_Resurrection_System**: The system that manages resurrection of dead shadows, including cost calculation, cooldown tracking, and weakened revival state.
- **Relic**: A special item awarded after the first boss defeat, containing a 3x3 grid for shard placement.
- **Relic_Grid**: The 3x3 (9-slot) grid within the Relic where shards are placed.
- **Shard**: A 1x1 item that occupies one slot in the Relic_Grid and provides a stat bonus to the player or shadows.
- **Adjacency_Bonus**: An additional stat bonus a Shard receives when an adjacent slot (cardinal direction) contains another Shard and that direction is one of the Shard's active receive directions.
- **Receive_Direction**: A cardinal direction (up, down, left, right) on a Shard that is "active" — meaning the Shard gains its Adjacency_Bonus when any other Shard occupies the neighboring slot in that direction.
- **Weakened_State**: A post-resurrection condition where a Shadow spawns at 50% of max health and heals over time back to full health.
- **Shard_Inventory**: The player's collection of all found shards, including those placed in the Relic_Grid and those unequipped.
- **Level_Transition**: The period between dungeon levels when the player can modify the Relic_Grid.
- **Enemy**: A hostile entity that the player and shadows fight. Defined in `enemy.gd`.
- **Boss**: A powerful Enemy that appears at the end of a dungeon floor.
- **Resurrection_Cooldown**: A per-shadow timer that must expire before that specific Shadow can be resurrected again.
- **Soul_Drop**: A collectible entity spawned at an Enemy's death position containing that Enemy's soul value. The necromancer must physically move over it to collect the souls.
- **Shard_Shop**: A between-levels shop interface that offers 5 randomly selected Shards for purchase with soul energy. Can be rerolled for a soul cost.

## Requirements

### Requirement 1: Soul Energy Earning

**User Story:** As a player, I want enemies to drop collectible souls when they die, so that I have to actively move to gather currency for resurrection and items.

#### Acceptance Criteria

1. WHEN an Enemy is killed, THE Enemy SHALL spawn a Soul_Drop at its death position containing soul energy based on the Enemy's soul value.
2. THE Soul_Energy_Manager SHALL assign a configurable soul value to each Enemy type, where tougher enemies have higher soul values.
3. WHEN the player's collision area overlaps a Soul_Drop, THE Soul_Energy_Manager SHALL add the Soul_Drop's soul value to the player's total and remove the Soul_Drop from the scene.
4. THE Soul_Drop SHALL remain in the scene until collected by the player or the run ends.
5. THE Soul_Drop SHALL display a visible pickup sprite or particle effect so the player can identify it on the ground.
6. THE Soul_Energy_Manager SHALL accumulate soul energy with no upper cap during a run.
7. THE Soul_Energy_Manager SHALL persist the soul energy total across level transitions within the same run.
8. WHEN a new run begins, THE Soul_Energy_Manager SHALL reset the soul energy total to zero.

### Requirement 2: Soul Energy Display

**User Story:** As a player, I want to see my current soul energy count, so that I can make informed decisions about spending.

#### Acceptance Criteria

1. THE Soul_Energy_Manager SHALL display the current soul energy total in the game HUD at all times during a run.
2. WHEN soul energy changes, THE Soul_Energy_Manager SHALL update the displayed total within the same frame.

### Requirement 3: Shadow Death and Resurrection Eligibility

**User Story:** As a player, I want my shadows to become eligible for resurrection after they die, so that I can bring them back into the fight.

#### Acceptance Criteria

1. WHEN a Shadow's health reaches zero, THE Shadow SHALL enter a dead state and stop attacking and following the player.
2. WHEN a Shadow dies, THE Shadow_Resurrection_System SHALL start a Resurrection_Cooldown timer for that specific Shadow.
3. WHILE a Shadow's Resurrection_Cooldown timer is active, THE Shadow_Resurrection_System SHALL prevent resurrection of that Shadow.
4. WHEN a Shadow's Resurrection_Cooldown expires, THE Shadow_Resurrection_System SHALL mark that Shadow as eligible for resurrection.
5. THE Shadow_Resurrection_System SHALL use a default Resurrection_Cooldown of 8 seconds for ShadowSkeleton and 12 seconds for ShadowWraith.

### Requirement 4: Shadow Resurrection Execution

**User Story:** As a player, I want to resurrect dead shadows by spending soul energy, so that I can recover my combat strength.

#### Acceptance Criteria

1. WHEN the player activates resurrection for an eligible Shadow, THE Shadow_Resurrection_System SHALL deduct the resurrection cost from the player's soul energy.
2. IF the player's soul energy is less than the resurrection cost, THEN THE Shadow_Resurrection_System SHALL reject the resurrection attempt and display an insufficient souls message.
3. THE Shadow_Resurrection_System SHALL calculate resurrection cost as a base cost per shadow type: 30 souls for ShadowSkeleton and 50 souls for ShadowWraith.
4. WHEN a Shadow is resurrected, THE Shadow_Resurrection_System SHALL spawn the Shadow at the player's current position.
5. WHEN a Shadow is resurrected, THE Shadow_Resurrection_System SHALL place the Shadow in Weakened_State with 50% of max health.
6. WHILE a Shadow is in Weakened_State, THE Shadow SHALL regenerate health at a rate of 5 HP per second until reaching max health.
7. WHEN a Shadow in Weakened_State reaches max health, THE Shadow SHALL exit Weakened_State.

### Requirement 5: Resurrection UI Indicators

**User Story:** As a player, I want to see which shadows are dead, their cooldown status, and the resurrection cost, so that I can plan my resurrections.

#### Acceptance Criteria

1. WHEN a Shadow is dead and on cooldown, THE Shadow_Resurrection_System SHALL display the remaining cooldown time in the HUD.
2. WHEN a Shadow is eligible for resurrection, THE Shadow_Resurrection_System SHALL display the resurrection cost and a visual indicator that resurrection is available.
3. WHEN the player has insufficient soul energy for a resurrection, THE Shadow_Resurrection_System SHALL visually dim the resurrection indicator for that Shadow.

### Requirement 6: Relic Acquisition

**User Story:** As a player, I want to receive a Relic after defeating the first boss, so that I can start placing shards for stat bonuses.

#### Acceptance Criteria

1. WHEN the player defeats the first Boss, THE Relic SHALL be awarded to the player.
2. IF the player already owns a Relic, THEN THE Relic SHALL not be awarded again.
3. THE Relic SHALL contain a Relic_Grid of 3 rows by 3 columns (9 total slots).
4. WHEN the Relic is first acquired, THE Relic_Grid SHALL be empty with all 9 slots available.

### Requirement 7: Shard Placement and Removal

**User Story:** As a player, I want to place and rearrange shards in my relic grid between levels, so that I can optimize my build.

#### Acceptance Criteria

1. WHILE in a Level_Transition, THE Relic_Grid SHALL allow the player to place a Shard from the Shard_Inventory into any empty slot.
2. WHILE in a Level_Transition, THE Relic_Grid SHALL allow the player to remove a placed Shard back to the Shard_Inventory.
3. WHILE in a Level_Transition, THE Relic_Grid SHALL allow the player to swap a placed Shard with another Shard from the Shard_Inventory.
4. THE Relic_Grid SHALL occupy each Shard in exactly one slot (1x1 size).
5. WHILE in active combat, THE Relic_Grid SHALL prevent all placement, removal, and swap operations.
6. THE Relic_Grid SHALL apply shard placement and removal changes with zero soul cost.

### Requirement 8: Shard Adjacency Bonus Calculation

**User Story:** As a player, I want shards to gain bonuses from adjacent shards based on their active receive directions, so that placement strategy matters.

#### Acceptance Criteria

1. THE Relic_Grid SHALL evaluate Adjacency_Bonus for each placed Shard whenever the grid contents change.
2. WHEN a Shard has a Receive_Direction that is active and the adjacent slot in that direction contains any other Shard, THE Relic_Grid SHALL apply one Adjacency_Bonus to the receiving Shard.
3. THE Relic_Grid SHALL only consider cardinal directions (up, down, left, right) for adjacency evaluation.
4. THE Relic_Grid SHALL not apply Adjacency_Bonus for diagonal neighbors.
5. WHEN a Shard has multiple active Receive_Directions with occupied adjacent slots, THE Relic_Grid SHALL apply one Adjacency_Bonus per qualifying direction.
6. FOR ALL valid Relic_Grid configurations, serializing the grid state then deserializing it SHALL produce an equivalent grid configuration with identical Adjacency_Bonus calculations (round-trip property).

### Requirement 9: Shard Stat Effects

**User Story:** As a player, I want shards to provide meaningful stat bonuses, so that I can customize my build.

#### Acceptance Criteria

1. THE Relic_Grid SHALL support the following shard stat types: cooldown reduction, damage amplification, attack speed, healing rate, max health bonus, movement speed, soul earning bonus, and critical hit chance.
2. THE Relic_Grid SHALL apply each Shard's base stat bonus to the player and all active shadows.
3. WHEN a Shard receives one or more Adjacency_Bonuses, THE Relic_Grid SHALL increase that Shard's effective stat value by a percentage per active adjacency (e.g., +25% per adjacent shard).
4. THE Relic_Grid SHALL recalculate all effective stat values whenever a Shard is placed, removed, or swapped.
5. THE Relic_Grid SHALL apply the combined stat bonuses from all placed Shards as modifiers to the base stats of the player and shadows.

### Requirement 10: Shard Types (v1 Pool)

**User Story:** As a player, I want a variety of shard types with different stats and active directions, so that I have interesting placement choices.

#### Acceptance Criteria

1. THE Relic_Grid SHALL support a pool of 8 to 10 distinct Shard types for v1.
2. Each Shard type SHALL have a unique combination of stat type, base value, Adjacency_Bonus value, and set of active Receive_Directions.
3. Each Shard type SHALL have between 1 and 4 active Receive_Directions.
4. THE Relic_Grid SHALL include at least one Shard type for each of the following stats: cooldown reduction, damage amplification, attack speed, and healing rate.

### Requirement 11: Shard Selling

**User Story:** As a player, I want to sell unwanted shards for soul energy, so that I can convert unneeded shards into resurrection currency.

#### Acceptance Criteria

1. WHILE in a Level_Transition, THE Shard_Inventory SHALL allow the player to sell any unequipped Shard for a soul energy value.
2. WHEN a Shard is sold, THE Soul_Energy_Manager SHALL add the Shard's sell value to the player's soul energy total.
3. WHEN a Shard is sold, THE Shard_Inventory SHALL permanently remove that Shard from the player's collection.
4. THE Shard_Inventory SHALL assign each Shard type a configurable sell value in soul energy.

### Requirement 12: Shard Shop

**User Story:** As a player, I want to buy shards from a shop between levels, so that I can strategically build up my relic using the souls I've earned.

#### Acceptance Criteria

1. WHEN a Level_Transition begins, THE Shard_Shop SHALL present 5 randomly selected Shards from the v1 shard pool to the player.
2. Each offered Shard SHALL display its stat type, base value, active Receive_Directions, and purchase price in soul energy.
3. THE Shard_Shop SHALL assign each Shard type a configurable purchase price, where shards with more active Receive_Directions or stronger stats cost more.
4. WHEN the player purchases a Shard, THE Soul_Energy_Manager SHALL deduct the Shard's purchase price from the player's soul energy total.
5. IF the player's soul energy is less than a Shard's purchase price, THE Shard_Shop SHALL prevent the purchase and visually indicate insufficient funds.
6. WHEN a Shard is purchased, THE Shard_Inventory SHALL add the Shard to the player's collection.
7. THE Shard_Shop SHALL allow the player to reroll the 5 offered Shards for a configurable soul energy cost.
8. WHEN the player rerolls, THE Shard_Shop SHALL replace all unpurchased offered Shards with 5 new randomly selected Shards from the v1 pool.
9. THE Shard_Shop SHALL allow multiple rerolls as long as the player has sufficient soul energy.
10. THE Shard_Shop SHALL be accessible only during Level_Transition, alongside the Relic_Grid management.

### Requirement 13: Weakened State Visual Feedback

**User Story:** As a player, I want to see when a shadow is in a weakened state after resurrection, so that I can protect it while it recovers.

#### Acceptance Criteria

1. WHILE a Shadow is in Weakened_State, THE Shadow SHALL display a distinct visual indicator (pulsing or dimmed teal tint).
2. WHEN a Shadow exits Weakened_State, THE Shadow SHALL return to the standard teal tint visual.
3. WHILE a Shadow is in Weakened_State, THE Shadow SHALL display a health bar that visually reflects the ongoing health regeneration.

### Requirement 14: Relic Grid State Persistence

**User Story:** As a player, I want my relic grid configuration to persist across levels within a run, so that I do not lose my shard arrangement.

#### Acceptance Criteria

1. THE Relic_Grid SHALL persist the positions of all placed Shards across level transitions within the same run.
2. THE Shard_Inventory SHALL persist all collected Shards across level transitions within the same run.
3. WHEN a new run begins, THE Relic_Grid SHALL reset to an empty state.
4. WHEN a new run begins, THE Shard_Inventory SHALL reset to an empty collection.
5. FOR ALL Relic_Grid states, serializing the grid then deserializing it SHALL produce an identical grid state (round-trip property).
