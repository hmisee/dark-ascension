# Enemy System Documentation

## Overview
Two enemy types with different behaviors, health systems, and combat mechanics.

## Enemy Types

### 1. Skeleton (Melee)
- **Health**: 30 HP
- **Speed**: 100 pixels/second
- **Behavior**: Aggressively chases player
- **Damage**: 8 contact damage
- **Visual**: Beige/tan colored simple humanoid shape
- **Strategy**: Fast melee attacker, dangerous in groups

### 2. Ghost (Ranged)
- **Health**: 20 HP
- **Speed**: 60 pixels/second
- **Behavior**: Keeps distance, shoots projectiles
- **Attack Range**: 200 pixels
- **Min Distance**: 150 pixels (retreats if player gets closer)
- **Attack Cooldown**: 2 seconds
- **Projectile Damage**: 10 HP
- **Visual**: Blue/cyan ghostly shape with glow effect
- **Strategy**: Kiting enemy, maintains optimal range

## Combat Mechanics

### Player vs Enemies
- Player projectiles deal 10 damage
- Enemies flash red when hit
- Health bars show above enemies
- Enemies die at 0 HP

### Enemies vs Player
- Contact damage when touching player
- Ghost projectiles (red) damage player
- Player has 100 HP
- Player flashes red when hit
- Game restarts on player death

## Spawning System

### Enemy Spawner
- **Location**: Added to arena_test scene
- **Spawn Interval**: 3 seconds
- **Max Enemies**: 15 at once
- **Spawn Distance**: 400 pixels from player
- **Spawn Distribution**: 70% Skeletons, 30% Ghosts
- **First Spawn**: 1 second after game starts

### Spawn Behavior
- Enemies spawn in circle around player
- Random angle for each spawn
- Spawning pauses when max enemies reached
- Resumes when enemies are killed

## Collision Layers

- **Layer 1**: Player
- **Layer 2**: Player projectiles
- **Layer 4**: Enemies
- **Layer 8**: Enemy projectiles

## Visual Feedback

### Damage Indicators
- Red flash on hit (0.1 seconds)
- Health bar updates immediately
- Console messages for player damage

### Enemy Death
- Enemy despawns immediately
- Spawner notified to allow new spawns
- No death animation yet (placeholder)

## Customization

### In Enemy Scripts
- `max_health`: Starting HP
- `move_speed`: Movement speed
- `contact_damage`: Damage on touch
- `damage`: Projectile damage (Ghost only)

### In Enemy Spawner
- `spawn_interval`: Time between spawns
- `spawn_distance`: How far from player
- `max_enemies`: Maximum concurrent enemies

## Future Enhancements

### Planned Features
- Death animations
- Drop items/experience
- Elite variants with more HP
- Boss enemies
- Different attack patterns
- Sound effects
- Particle effects

### Art Replacement
Current enemies use simple colored shapes. Replace with:
1. Import sprite sheets to `assets/sprites/enemies/`
2. Update enemy scenes with AnimatedSprite2D
3. Add idle/walk/attack animations
4. Keep same script logic

## Testing

Run the arena_test scene:
1. Enemies spawn around you every 3 seconds
2. Skeletons chase you aggressively
3. Ghosts keep distance and shoot red projectiles
4. Your teal projectiles damage enemies
5. Avoid contact and enemy projectiles
6. Game restarts if you die

## Known Issues

- No death animations
- Simple placeholder graphics
- No enemy variety beyond 2 types
- No difficulty scaling
- Player death just restarts scene
