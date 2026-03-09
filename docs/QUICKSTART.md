# Quick Start Guide

## Opening the Project

1. Launch Godot 4
2. Click "Import" in the project manager
3. Navigate to the project folder and select `project.godot`
4. Click "Import & Edit"

## Project Structure

The project is now set up with:

- **project.godot** - Main project configuration
- **scenes/** - Game scenes (main menu created)
- **scripts/** - GDScript code organized by purpose
  - autoloads/ - Global managers (GameManager)
  - systems/ - Core systems (ShadowSystem, BackpackSystem)
  - entities/ - Character/enemy scripts (to be added)
- **assets/** - Sprites, audio, fonts (ready for content)

## Next Steps

1. Generate sprites using Stable Diffusion (see SETUP.md)
2. Build the dungeon scene
3. Implement shadow and combat systems
4. Create the backpack UI

## Running the Game

Press F5 in Godot or click the Play button. The main menu will appear.

## Development Workflow

1. Design → Implement → Test
2. Use the game design doc as reference
3. Generate assets as needed
4. Iterate on gameplay feel
