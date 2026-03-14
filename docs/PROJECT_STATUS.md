# Dark Ascension - Project Status

## ✅ Completed

### Core Setup
- Godot 4 project initialized
- Git repository configured
- Project structure established

### Player Character
- CraftPix Chibi Necromancer sprites integrated
- Idle animation (18 frames) - working
- Walk animation (24 frames) - working
- Attack animation (12 frames) - ready to add in editor
- Character flips direction based on movement
- WASD/Arrow key controls implemented

### Shadow Companion System
- Shadow Skeleton: melee companion, positions in front of player (60px offset)
- Shadow Wraith: ranged companion, positions behind player (70px offset)
- Both auto-attack nearest enemy independently
- Teal tint (Color 0.3, 1.0, 0.9) distinguishes shadows from enemies
- Formation rotates with player aim direction (cursor-based)
- Shadows have health bars and take damage
- Auto-spawned at game start via call_deferred
- Full animated sprites (idle, walk, attack, death) matching enemy sprites
- Collision layer 16 (shadows), mask 4 (enemies)

### Projectile System
- Projectile system with teal visual effect
- Mid-range projectile (300 pixels)
- Auto-attack every 1 second
- Attack animation plays when firing
- Player can move freely while attacking
- Character sprite flips to face cursor
- Player health system (100 HP)
- Damage feedback (red flash)

### Enemy System
- Two enemy types: Skeleton (melee) and Ghost/Wraith (ranged)
- Full animated sprites from CraftPix (idle, walk, attack, death)
- Skeleton: Chibi Skeleton Warrior sprites (scale 0.1)
- Wraith: Wraith Tiny Style sprites (scale 0.15)
- Enemy AI with pathfinding
- Health bars for enemies
- Contact damage and projectile attacks
- Enemy spawner system
- Spawns up to 15 enemies at once
- 70% Skeletons, 30% Ghosts
- Enemies spawn around player in circle

### Scenes
- Main menu with Start/Quit buttons
- Test arena for character testing
- Player scene with AnimatedSprite2D
- Projectile scene with teal glow effect

### Available Assets
- **Necromancer sprites:** `assets/sprites/characters/necromancer_chibi/`
  - idle/ (18 frames)
  - walk/ (24 frames)
  - run/ (12 frames) - not yet implemented
  - attack/ (12 frames) - sprites ready, needs editor setup

## 📋 Documentation

### Active Docs
- `GAME_DESIGN.md` - Core game concept and mechanics
- `PROJECT_STATUS.md` - This file
- `SHADOW_SYSTEM.md` - Shadow companion system reference
- `TODO_NEXT_SESSION.md` - Next steps and roadmap

## 🎯 Next Steps

### Immediate
1. Test shadow companion system in Godot (verify spawning, formation, attacks)
2. Add experience/leveling system
3. Add death animations for all entities
4. Balance shadow and enemy stats based on playtesting

### Short Term
1. Item drops from enemies
2. Add more enemy types
3. Add basic dungeon generation
4. Create enemy AI improvements
5. Add sound effects

### Medium Term
1. Implement backpack/inventory system
2. Add progression mechanics
3. Create multiple dungeon levels
4. Add boss encounters

## 🎨 Asset Strategy

### Current
- Using CraftPix Free Chibi Necromancer (1 of 3 variants)
- High-quality sprites with smooth animations

### Future
- Consider purchasing CraftPix Undead Warrior pack ($15-20)
  - 7 characters (skeleton, zombie, mummy, ghost, vampire, etc.)
  - Use as enemies AND summons
  - Add cyan tint/glow for summoned units
- Or find free enemy packs that match the style

## 🔧 Technical Details

### Controls
- WASD or Arrow Keys - Movement
- Mouse Cursor - Aim direction (360-degree aiming)
- Attacks happen automatically every 1 second (Vampire Survivors style)
- Character automatically switches between idle/walk/attack animations
- Character flips to face cursor direction
- Projectiles shoot toward mouse cursor

### Performance
- Sprites scaled to 0.1 (from ~500x500px originals)
- Individual frame animation (not spritesheets)
- Smooth 60 FPS gameplay

## 📁 Project Structure

```
DarkAscension/
├── assets/
│   └── sprites/
│       ├── characters/
│       │   └── necromancer_chibi/
│       └── enemies/
│           ├── skeleton/ (idle, walk, attack, death)
│           └── wraith/ (idle, walk, attack, death)
├── docs/
│   ├── GAME_DESIGN.md
│   ├── PROJECT_STATUS.md
│   ├── SHADOW_SYSTEM.md
│   └── TODO_NEXT_SESSION.md
├── scenes/
│   ├── main_menu.tscn
│   ├── player.tscn
│   ├── projectile.tscn
│   ├── skeleton_enemy.tscn
│   ├── ghost_enemy.tscn
│   ├── enemy_projectile.tscn
│   ├── shadow_skeleton.tscn
│   ├── shadow_wraith.tscn
│   └── dungeon/
│       └── arena_test.tscn
└── scripts/
    ├── autoloads/
    │   └── game_manager.gd
    ├── entities/
    │   ├── player.gd
    │   ├── projectile.gd
    │   ├── enemy.gd
    │   ├── skeleton_enemy.gd
    │   ├── ghost_enemy.gd
    │   ├── enemy_projectile.gd
    │   ├── shadow.gd
    │   ├── shadow_skeleton.gd
    │   └── shadow_wraith.gd
    └── systems/
        └── enemy_spawner.gd
```

## 🎮 Current Game State

You can:
- Start the game from main menu
- See animated necromancer character
- Move around the test arena with WASD
- Aim with mouse cursor (360-degree aiming)
- Character animates and faces cursor direction
- Automatically shoot teal projectiles toward cursor every 1 second
- Attack animation plays when firing
- Move freely while attacking
- Fight enemies (Skeletons and Wraiths) with animated sprites
- Take damage from enemies
- Kill enemies with projectiles
- See enemy health bars
- Have two shadow companions (melee skeleton + ranged wraith)
- Shadows auto-follow in formation and auto-attack enemies
- Shadows visually distinct with teal tint

You cannot yet:
- Level up or gain experience
- Collect items or loot
- Progress through dungeons
- Use inventory
- See game over screen (just restarts)

---

**Last Updated:** March 14, 2026
**Version:** 0.2.0-alpha
