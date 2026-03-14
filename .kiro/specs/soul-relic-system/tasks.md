# Implementation Plan: Soul & Relic System

## Overview

Implements the soul energy economy, shadow resurrection mechanics, and relic shard grid system for Dark Ascension. Tasks are ordered so each step builds on the previous: core data types first, then systems, then integration, then UI, then tests. All code is GDScript targeting Godot 4.

## Tasks

- [x] 1. Create foundational data types and resources
  - [x] 1.1 Create the Shard resource class
    - Create `scripts/systems/shard.gd` as a `Resource` with `class_name Shard`
    - Define `StatType` enum (COOLDOWN_REDUCTION, DAMAGE_AMP, ATTACK_SPEED, HEALING_RATE, MAX_HEALTH, MOVEMENT_SPEED, SOUL_BONUS, CRIT_CHANCE)
    - Define `Direction` enum (UP, DOWN, LEFT, RIGHT)
    - Add exported properties: `shard_name`, `stat_type`, `base_value`, `adjacency_bonus_percent`, `receive_directions`, `purchase_price`, `sell_value`
    - Implement `get_effective_value(active_adjacency_count: int) -> float` using formula `base_value * (1 + count * adjacency_bonus_percent / 100)`
    - Implement `serialize() -> Dictionary` and `static func deserialize(data: Dictionary) -> Shard`
    - _Requirements: 9.1, 9.3, 10.2, 10.3_

  - [x] 1.2 Create the v1 shard pool data
    - Create `scripts/data/shard_pool.gd` with a static function returning an Array of all 8 shard type definitions
    - Define all 8 shards: Bone Fragment, Blood Crystal, Swift Essence, Vital Marrow, Soul Stone, Phantom Shard, Reaper's Eye, Death's Edge
    - Each shard has unique stat_type, base_value, adjacency_bonus_percent, receive_directions, purchase_price, sell_value per the design table
    - Include a helper `get_shard_by_name(name: String) -> Shard` for lookups
    - _Requirements: 10.1, 10.2, 10.3, 10.4_

  - [x]* 1.3 Write property test for shard pool invariants
    - **Property 15: Shard pool invariants**
    - Verify all shard types have unique (stat_type, base_value, adjacency_bonus_percent, receive_directions) combinations
    - Verify each shard type has between 1 and 4 active receive directions
    - Verify at least one shard exists for cooldown_reduction, damage_amp, attack_speed, and healing_rate
    - **Validates: Requirements 10.2, 10.3**

  - [x]* 1.4 Write property test for effective shard value formula
    - **Property 8: Effective shard value with adjacency bonus**
    - Generate random (base_value, bonus_percent, adjacency_count) tuples
    - Verify `get_effective_value(N)` equals `base_value * (1 + N * adjacency_bonus_percent / 100)` for all inputs
    - **Validates: Requirements 9.3**

- [x] 2. Implement SoulEnergyManager autoload
  - [x] 2.1 Create the SoulEnergyManager autoload script
    - Create `scripts/autoloads/soul_energy_manager.gd` extending Node
    - Implement `current_souls: int`, signal `souls_changed(new_total: int)`
    - Implement `add_souls(amount: int)`, `spend_souls(amount: int) -> bool`, `get_souls() -> int`, `reset()`
    - `spend_souls` returns false if amount > current_souls with no partial deduction
    - Register as autoload in project settings
    - _Requirements: 1.3, 1.6, 1.7, 1.8_

  - [x]* 2.2 Write property test for soul accumulation
    - **Property 1: Soul accumulation is additive**
    - Generate random lists of positive integers, add them all, verify total equals sum
    - **Validates: Requirements 1.3, 1.6**

- [x] 3. Implement SoulDrop entity and enemy integration
  - [x] 3.1 Create the SoulDrop scene and script
    - Create `scripts/entities/soul_drop.gd` extending Area2D with `@export var soul_value: int = 10`
    - On `body_entered` (player group): call `SoulEnergyManager.add_souls(soul_value)` and `queue_free()`
    - Create `scenes/soul_drop.tscn` with Sprite2D (pickup visual), CollisionShape2D (small circle)
    - Set collision layer 8 (pickups), mask layer 1 (player)
    - _Requirements: 1.1, 1.3, 1.4, 1.5_

  - [x] 3.2 Modify Enemy to spawn SoulDrop on death
    - Add `@export var soul_value: int = 10` and `@export var soul_drop_scene: PackedScene` to `enemy.gd`
    - Modify `die()` to instantiate `soul_drop_scene` at death position with the enemy's `soul_value`
    - Set default soul values: skeleton_enemy = 10, ghost_enemy = 15
    - Update `scenes/skeleton_enemy.tscn` and `scenes/ghost_enemy.tscn` to reference `soul_drop.tscn` and set soul values
    - _Requirements: 1.1, 1.2_

- [x] 4. Checkpoint — Verify soul economy
  - Ensure soul drops spawn on enemy death, player can collect them, and SoulEnergyManager tracks the total correctly. Ask the user if questions arise.

- [x] 5. Implement Shadow Resurrection System
  - [x] 5.1 Modify Shadow base class for death and resurrection
    - Add `is_weakened: bool = false` and `regen_rate: float = 5.0` to `shadow.gd`
    - Modify `die()` to hide the shadow (set visible = false, disable processing) instead of `queue_free()`, emit a `shadow_died` signal
    - Add `resurrect_at(pos: Vector2)` — resets state, sets HP to 50% max, sets `is_weakened = true`, shows shadow
    - Add `_process_weakened_state(delta)` — regenerates HP at `regen_rate` per second, exits weakened state when HP reaches max
    - Add weakened visual: pulsing teal tint via modulate oscillation while `is_weakened`
    - _Requirements: 3.1, 4.4, 4.5, 4.6, 4.7, 13.1, 13.2, 13.3_

  - [x] 5.2 Create ShadowResurrectionSystem
    - Create `scripts/systems/shadow_resurrection_system.gd` extending Node
    - Define signals: `shadow_died`, `cooldown_updated`, `shadow_ready`, `resurrection_failed`
    - Implement per-shadow-type config: costs (skeleton=30, wraith=50), cooldowns (skeleton=8s, wraith=12s)
    - Implement `on_shadow_died(shadow_type)` — starts cooldown timer
    - Implement `try_resurrect(shadow_type) -> bool` — checks cooldown expired AND sufficient souls, deducts souls, calls `resurrect_at()` on the shadow
    - Implement `_process(delta)` — ticks cooldowns, emits `cooldown_updated` and `shadow_ready` signals
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3_

  - [x] 5.3 Integrate resurrection system with Player
    - Add ShadowResurrectionSystem as a child node of Player or wire it in `player.gd`
    - Replace existing `handle_shadow_respawns()` logic with calls to `ShadowResurrectionSystem`
    - Add input handling for resurrection keys (e.g., press 1 for skeleton, 2 for wraith)
    - Connect shadow `shadow_died` signals to `ShadowResurrectionSystem.on_shadow_died()`
    - _Requirements: 4.1, 4.4_

  - [x]* 5.4 Write property test for resurrection gating
    - **Property 2: Resurrection gating by cooldown and soul cost**
    - Generate random (shadow_type, soul_balance, cooldown_elapsed) tuples
    - Verify resurrection succeeds iff cooldown expired AND souls >= cost, with exact deduction on success and no change on failure
    - **Validates: Requirements 3.3, 3.4, 4.1, 4.2**

  - [x]* 5.5 Write property test for weakened state regeneration
    - **Property 3: Weakened state health regeneration lifecycle**
    - Generate random (max_health, elapsed_time) pairs
    - Verify health equals `min(max_health, 0.5 * max_health + 5.0 * t)` and weakened state exits at max health
    - **Validates: Requirements 4.5, 4.6, 4.7**

- [x] 6. Checkpoint — Verify shadow resurrection
  - Ensure shadows enter dead state on death, cooldowns tick correctly, resurrection costs souls and spawns weakened shadow, and weakened state heals over time. Ask the user if questions arise.

- [x] 7. Implement RelicGrid system
  - [x] 7.1 Create the RelicGrid resource
    - Create `scripts/systems/relic_grid.gd` as a Resource with `class_name RelicGrid`
    - Implement 3x3 grid array, `is_unlocked: bool`
    - Implement `place_shard(shard, row, col) -> bool` — validates bounds, empty slot, unlocked, not in combat
    - Implement `remove_shard(row, col) -> Shard` — returns shard or null
    - Implement `swap_shard(row, col, new_shard) -> Shard` — returns old shard
    - Implement `get_shard(row, col) -> Shard`
    - Implement `reset()` — clears grid and sets `is_unlocked = false`
    - All mutation methods return false/null during active combat (check GameManager state)
    - _Requirements: 6.3, 6.4, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 7.2 Implement adjacency bonus calculation
    - Implement `calculate_all_bonuses() -> Dictionary` in RelicGrid
    - For each placed shard, count active adjacencies by checking each receive_direction's cardinal neighbor
    - Compute effective value per shard using `get_effective_value(active_count)`
    - Aggregate effective values by stat_type across all placed shards
    - Implement `recalculate()` to trigger bonus recalculation on any grid change
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 9.2, 9.3, 9.4, 9.5_

  - [x] 7.3 Implement RelicGrid serialization
    - Implement `serialize() -> Dictionary` and `static func deserialize(data: Dictionary) -> RelicGrid`
    - Serialize grid as 3x3 array of shard data or null, plus `is_unlocked` flag
    - Handle corrupt/missing data gracefully with defaults
    - _Requirements: 8.6, 14.1, 14.5_

  - [x]* 7.4 Write property test for grid structural invariant
    - **Property 4: Relic grid structural invariant**
    - Generate random grid states via random shard placements
    - Verify grid is always 3x3 and each shard occupies exactly one slot
    - **Validates: Requirements 6.3, 7.4**

  - [x]* 7.5 Write property test for place/remove round trip
    - **Property 5: Shard place-then-remove round trip**
    - Generate random (shard, row, col) on empty grids
    - Verify placing then removing returns grid to prior state and returns the same shard
    - **Validates: Requirements 7.1, 7.2**

  - [x]* 7.6 Write property test for cardinal adjacency calculation
    - **Property 7: Cardinal directional adjacency calculation**
    - Generate random grid configurations
    - Verify each shard's active adjacency count matches the number of receive_directions with an occupied cardinal neighbor
    - **Validates: Requirements 8.2, 8.3, 8.4, 8.5**

  - [x]* 7.7 Write property test for total stat bonus aggregation
    - **Property 9: Total stat bonus aggregation**
    - Generate random grid configurations with mixed shard types
    - Verify total bonus per stat type equals sum of effective values of all placed shards of that type
    - **Validates: Requirements 9.2, 9.5**

  - [x]* 7.8 Write property test for grid serialization round trip
    - **Property 10: Relic grid serialization round trip**
    - Generate random grid states
    - Verify serialize then deserialize produces identical grid state with identical adjacency calculations
    - **Validates: Requirements 8.6, 14.1, 14.5**

  - [x]* 7.9 Write property test for combat lockout
    - **Property 6: Combat lockout of grid and shop operations**
    - Generate random grid/shop operations during combat state
    - Verify all operations are rejected with no state change
    - **Validates: Requirements 7.5, 12.10**

  - [x]* 7.10 Write property test for grid operations zero soul cost
    - **Property 17: Grid operations have zero soul cost**
    - Generate random (operation, shard, position, initial_souls) tuples
    - Verify soul balance is identical before and after any grid operation
    - **Validates: Requirements 7.6**

- [x] 8. Implement ShardInventory and selling
  - [x] 8.1 Create ShardInventory
    - Create `scripts/systems/shard_inventory.gd` extending Node
    - Implement `shards: Array[Shard]`, signal `inventory_changed()`
    - Implement `add_shard(shard)`, `remove_shard(shard) -> bool`, `get_all() -> Array[Shard]`, `reset()`
    - Implement `sell_shard(shard) -> bool` — removes shard and calls `SoulEnergyManager.add_souls(shard.sell_value)`
    - Selling only allowed during level transition (check GameManager state)
    - Implement serialization: `serialize() -> Array` and `static func deserialize(data: Array) -> Array[Shard]`
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 14.2, 14.4_

  - [x]* 8.2 Write property test for shard selling
    - **Property 12: Shard selling adds souls and removes from inventory**
    - Generate random (shard, initial_souls) pairs
    - Verify selling increases souls by exactly sell_value and removes shard from inventory
    - **Validates: Requirements 11.1, 11.2, 11.3**

  - [x]* 8.3 Write property test for inventory serialization round trip
    - **Property 11: Shard inventory serialization round trip**
    - Generate random shard collections
    - Verify serialize then deserialize produces identical collection
    - **Validates: Requirements 14.2**

- [x] 9. Implement ShardShop
  - [x] 9.1 Create ShardShop system
    - Create `scripts/systems/shard_shop.gd` extending Node
    - Implement `offer_count = 5`, `reroll_cost = 20`, signal `shop_updated(offers)`
    - Implement `generate_offers()` — picks 5 random shards from shard pool
    - Implement `purchase(index: int) -> bool` — checks soul balance >= price, deducts souls, adds shard to ShardInventory, marks slot as sold
    - Implement `reroll() -> bool` — checks soul balance >= reroll_cost, deducts cost, regenerates 5 new offers
    - Shop only accessible during level transition
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 12.10_

  - [x]* 9.2 Write property test for shop purchase gating
    - **Property 13: Shop purchase gating by soul cost**
    - Generate random (offer_index, soul_balance) pairs
    - Verify purchase succeeds iff souls >= price, with exact deduction and shard added to inventory on success, no change on failure
    - **Validates: Requirements 12.4, 12.5, 12.6**

  - [x]* 9.3 Write property test for shop reroll
    - **Property 14: Shop reroll replaces offers**
    - Generate random (soul_balance, reroll_cost) pairs
    - Verify reroll deducts cost and presents exactly 5 new shards from the v1 pool when souls are sufficient
    - **Validates: Requirements 12.7, 12.8, 12.9**

- [x] 10. Checkpoint — Verify relic grid, inventory, and shop
  - Ensure shard placement/removal/swap works, adjacency bonuses calculate correctly, selling adds souls, shop purchase and reroll work with proper gating. Ask the user if questions arise.

- [x] 11. Implement relic acquisition and run lifecycle
  - [x] 11.1 Add relic award logic
    - Modify GameManager or boss death handler to award the relic (`relic_grid.is_unlocked = true`) on first boss defeat
    - Ensure idempotence: if relic already unlocked, do nothing
    - Initialize relic grid as empty 3x3 on award
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 11.2 Implement run reset for all new systems
    - On new run: call `SoulEnergyManager.reset()`, `RelicGrid.reset()`, `ShardInventory.reset()`
    - Ensure soul energy resets to 0, relic grid clears, inventory empties
    - Wire into existing GameManager new run flow
    - _Requirements: 1.8, 14.3, 14.4_

  - [x] 11.3 Implement state persistence across level transitions
    - Serialize soul energy, relic grid, shard inventory, and dead shadow state during level transitions
    - Deserialize and restore on level load
    - _Requirements: 1.7, 14.1, 14.2_

  - [x]* 11.4 Write property test for relic award idempotence
    - **Property 16: Relic award idempotence**
    - Generate random player states with/without relic
    - Verify awarding relic twice produces same state as awarding once
    - **Validates: Requirements 6.2**

- [x] 12. Implement UI elements
  - [x] 12.1 Add soul energy HUD display
    - Create or modify HUD scene to show current soul energy total
    - Connect to `SoulEnergyManager.souls_changed` signal for real-time updates
    - _Requirements: 2.1, 2.2_

  - [x] 12.2 Add shadow resurrection HUD indicators
    - Display dead shadow cooldown timers in HUD
    - Show resurrection cost and "ready" indicator when cooldown expires
    - Dim resurrection indicator when player has insufficient souls
    - Connect to ShadowResurrectionSystem signals (`cooldown_updated`, `shadow_ready`, `resurrection_failed`)
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 12.3 Create relic grid UI for level transitions
    - Create a relic grid UI panel showing the 3x3 grid with placed shards
    - Allow drag-and-drop or click-to-place shard placement from inventory
    - Allow click-to-remove shard removal back to inventory
    - Allow swap by placing a shard on an occupied slot
    - Show each shard's stat type, base value, and active receive directions
    - Display calculated adjacency bonuses per shard
    - Only enabled during level transitions
    - _Requirements: 7.1, 7.2, 7.3, 7.5, 8.1, 9.4_

  - [x] 12.4 Create shard shop UI for level transitions
    - Create shop panel showing 5 shard offers with stat info, directions, and prices
    - Add purchase buttons with insufficient-funds visual dimming
    - Add reroll button showing reroll cost
    - Connect to ShardShop signals and SoulEnergyManager for balance checks
    - Only enabled during level transitions
    - _Requirements: 12.1, 12.2, 12.3, 12.5, 12.7, 12.10_

  - [x] 12.5 Add shard inventory UI panel
    - Show all unequipped shards in inventory with stat details and sell values
    - Add sell button per shard, disabled during combat
    - Connect to ShardInventory signals for real-time updates
    - _Requirements: 11.1, 11.4_

- [x] 13. Wire stat bonuses to player and shadows
  - [x] 13.1 Apply relic grid bonuses to player and shadow stats
    - After any grid change, call `RelicGrid.calculate_all_bonuses()` and apply modifiers to player and active shadows
    - Apply stat modifiers: cooldown_reduction, damage_amp, attack_speed, healing_rate, max_health, movement_speed, soul_bonus, crit_chance
    - Recalculate on level load (restore from persisted grid state)
    - _Requirements: 9.2, 9.4, 9.5_

- [x] 14. Create property-based test infrastructure
  - [x] 14.1 Create PropertyTestRunner helper
    - Create `tests/helpers/property_test_runner.gd` with a lightweight PBT utility
    - Accept a callable property and a generator function
    - Run property 100+ times with random inputs
    - Report first failing input on failure
    - Tag each test with `# Feature: soul-relic-system, Property {N}: {title}`

- [x] 15. Final checkpoint — Full integration verification
  - Ensure all systems work together: enemies drop souls, player collects them, shadows die and resurrect with costs and cooldowns, relic grid accepts shards with adjacency bonuses, shop and inventory work, stat bonuses apply, state persists across levels, and resets on new run. Ensure all tests pass. Ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The PropertyTestRunner (task 14.1) should be created before running any property tests, or property test tasks can create inline test loops
