# Shadow Companion System

## Overview
Two shadow companions follow the player in formation and auto-attack nearby enemies.
They use the same sprites as enemies but with a teal tint to distinguish them.

## Shadow Types

### Shadow Skeleton (Melee)
- Positions in FRONT of player (relative to aim direction)
- Close-range attacker (80 pixel range)
- High damage (20 per hit), fast cooldown (1 second)
- 60 HP
- Attacks by directly damaging the nearest enemy

### Shadow Wraith (Ranged)
- Positions BEHIND player (relative to aim direction)
- Long-range attacker (200 pixel range)
- Lower damage (12 per hit), slower cooldown (1.8 seconds)
- 40 HP
- Attacks by shooting a teal projectile at the nearest enemy

## Visual Distinction
Both shadows use `Color(0.3, 1.0, 0.9)` modulate on their AnimatedSprite2D.
This gives them a clear teal/cyan glow that distinguishes them from enemies.
When hit, they flash red briefly then return to teal.

## Formation System
Formation offsets are relative to the player's aim direction (cursor):
- Melee shadow: 60 pixels in front (in the direction the player is aiming)
- Ranged shadow: 70 pixels behind (opposite to aim direction)

As the player rotates their aim, the shadows smoothly reposition around them.

## Sprite Setup in Godot Editor

The shadow scenes share the same sprites as the enemies.
After setting up enemy sprites, do the following:

### Shadow Skeleton
1. Open `scenes/shadow_skeleton.tscn`
2. Select `AnimatedSprite2D`
3. In Inspector, assign the same `SpriteFrames` resource as `skeleton_enemy.tscn`
   - Open `skeleton_enemy.tscn`, click the SpriteFrames resource, copy it
   - Or simply drag the same resource into shadow_skeleton's SpriteFrames field
4. The teal tint is applied automatically by the script

### Shadow Wraith
1. Open `scenes/shadow_wraith.tscn`
2. Select `AnimatedSprite2D`
3. Assign the same `SpriteFrames` resource as `ghost_enemy.tscn`
4. The teal tint is applied automatically by the script

## Collision Layers
- Layer 16: Shadow bodies (don't collide with player or each other)
- Mask 4: Shadows detect enemies (for attack range checks)

## Customization

In `scripts/entities/shadow_skeleton.gd`:
- `formation_offset`: Position relative to player aim (x = front/back distance)
- `attack_range`: How close an enemy must be to trigger attack
- `attack_damage`: Damage per hit
- `attack_cooldown`: Seconds between attacks
- `max_health`: Shadow HP

In `scripts/entities/shadow_wraith.gd`:
- Same properties as above
- Also shoots projectiles instead of melee hits

In `scripts/entities/shadow.gd` (base):
- `follow_speed`: How fast shadows move to their formation position
- `TEAL_TINT`: The color applied to distinguish shadows from enemies
