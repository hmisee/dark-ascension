# Godot Project Setup

## Opening the Project

1. Launch Godot 4
2. Click "Import" in the project manager
3. Navigate to `D:\Development\DarkAscension`
4. Select `project.godot`
5. Click "Import & Edit"

## First Time Setup

When Godot opens, it will automatically import all assets. You'll see:
- ✅ Necromancer sprite in `assets/sprites/characters/`
- ✅ Player scene ready
- ✅ Test arena scene
- ✅ Main menu

## Testing the Player Character

### Option 1: Test Arena (Recommended)
1. In Godot, open `scenes/dungeon/arena_test.tscn`
2. Press F5 or click the Play button
3. Use WASD or Arrow Keys to move the necromancer

### Option 2: From Main Menu
1. Press F5 to run the project
2. Click "Start Game" button
3. Use WASD or Arrow Keys to move

## What You Should See

- Purple/black hooded necromancer sprite
- Character moves smoothly in all directions
- Camera follows the player
- Dark gray arena background

## Controls

- **WASD** or **Arrow Keys**: Move
- **ESC**: Quit (in test mode)
- **F5**: Run project
- **F6**: Run current scene

## Next Steps

Once movement feels good:
1. Add shadows that follow the player
2. Add enemy spawning
3. Implement auto-combat
4. Build the backpack system

## Troubleshooting

**Sprite not showing:**
- Check that `necromancer_idle.png` is in `assets/sprites/characters/`
- Godot should auto-import it

**Can't move:**
- Make sure you're running the arena_test scene or clicked Start Game
- Check that input map is set (should be default WASD/arrows)

**Scene won't open:**
- Ensure you're using Godot 4.x (not 3.x)
- Let Godot finish importing assets first
