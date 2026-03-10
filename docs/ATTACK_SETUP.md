# Attack System Setup Guide

## Overview
This guide explains how to complete the attack system setup for the necromancer character.

## What's Been Added

### 1. Projectile System
- **File**: `scripts/entities/projectile.gd`
- **Scene**: `scenes/projectile.tscn`
- Teal-colored projectile with glow effect
- Mid-range (300 pixels)
- Speed: 400 pixels/second
- Automatically despawns after max range

### 2. Player Attack Logic
- **File**: `scripts/entities/player.gd`
- Automatic attacks (Vampire Survivors style)
- 1 second cooldown between attacks
- Mouse cursor aiming - projectiles shoot toward cursor
- Attack animation plays when firing (0.3 seconds)
- Player can move freely while attacking
- Character sprite flips to face cursor direction

## Manual Setup Required

### Add Attack Animation to Player Scene

1. Open `scenes/player.tscn` in Godot Editor
2. Select the `AnimatedSprite2D` node
3. In the Inspector, click on the `SpriteFrames` resource
4. In the SpriteFrames panel (bottom), click "Add Animation"
5. Name it `attack`
6. Set the animation properties:
   - Speed: 12 FPS
   - Loop: OFF (uncheck)
7. Add the attack frames from:
   `assets/sprites/characters/necromancer_chibi/attack/`
   - Add frames 000 through 011 (12 frames total)
8. Save the scene

**Note:** The attack animation will play briefly (0.3 seconds) when firing, then return to idle/walk.

## Controls

- **WASD / Arrow Keys**: Move
- **Mouse Cursor**: Aim direction for projectiles
- Attacks happen automatically every 1 second (Vampire Survivors style)
- Attack animation plays when firing (if added in editor)

## Testing

1. Run the game
2. Move the character around with WASD
3. Move your mouse cursor around the screen
4. Teal projectiles will automatically shoot toward your cursor every 1 second
5. The attack animation plays briefly when firing
6. Character sprite flips to face the cursor
7. You can move freely while projectiles are firing

## Customization

### Projectile Settings (in `scripts/entities/projectile.gd`):
- `speed`: How fast the projectile travels
- `max_range`: How far the projectile goes before despawning

### Attack Settings (in `scripts/entities/player.gd`):
- `attack_cooldown`: Time between automatic attacks (default: 1.0 second)
- `attack_animation_duration`: How long attack animation plays (default: 0.3 seconds)

### Visual Customization (in `scenes/projectile.tscn`):
- Change the `color` property of the Polygon2D nodes to adjust the teal color
- Modify the `polygon` arrays to change the projectile shape
