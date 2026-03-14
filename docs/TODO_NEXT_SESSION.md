# TODO - Next Session

## ✅ Completed (Previous Sessions)

### Enemy Sprite Integration
- Downloaded and integrated CraftPix Chibi Skeleton Warrior sprites
- Downloaded and integrated CraftPix Wraith Tiny Style sprites
- Both enemies have idle, walk, attack, death animations
- Skeleton scale: 0.1, Wraith scale: 0.15

### Shadow Companion System
- Base shadow class with teal tint, formation following, auto-attack
- Shadow Skeleton (melee): 60px in front of player, 80px attack range
- Shadow Wraith (ranged): 70px behind player, shoots projectiles
- Full animated sprites copied from enemy scenes
- Collision layer 16 (shadows), mask 4 (enemies)
- Auto-spawned at game start

---

## 🔲 Next Up

### 1. Playtest & Fix Shadow System
- [ ] Run the game and verify shadows spawn with teal tint
- [ ] Verify formation positioning (melee front, ranged back relative to cursor)
- [ ] Verify shadow auto-attacks hit enemies
- [ ] Check collision masks are correct (enemies should be hittable)
- [ ] Adjust scale, distances, or attack ranges if needed

### 2. Experience & Leveling System
- [ ] XP drops from killed enemies
- [ ] XP bar UI
- [ ] Level-up mechanic (increase stats, unlock abilities)
- [ ] Visual/audio feedback on level up

### 3. Item Drops & Loot
- [ ] Enemies drop items on death
- [ ] Health pickups
- [ ] Damage boost pickups
- [ ] Speed boost pickups
- [ ] Visual pickup effects

### 4. More Enemy Types
- [ ] Consider adding 1-2 more enemy variants
- [ ] Boss enemy for wave milestones

### 5. Dungeon Generation
- [ ] Basic procedural room generation
- [ ] Room transitions
- [ ] Increasing difficulty per room

### 6. Sound Effects
- [ ] Attack sounds
- [ ] Hit/damage sounds
- [ ] Death sounds
- [ ] Background music

---

## Open Design Questions
- Shadow respawn mechanic? (timer, level-up, permanent?)
- Should shadows level up with the player?
- Inventory/backpack system design
- Game over screen vs. roguelike restart

---

**Priority**: Playtest shadows → XP system → Item drops
**Estimated Time**: 2-3 hours per feature
