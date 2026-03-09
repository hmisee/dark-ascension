# CraftPix Chibi Necromancer Integration Guide

## Assets Downloaded
**Pack:** Free Chibi Necromancer of the Shadow Character Sprites
**Source:** CraftPix.net
**Location:** `assets/sprites/characters/necromancer_chibi/`

## Available Animations

### Necromancer 1 (Copied)
- **Idle** - 10 frames
- **Walking** - 12 frames  
- **Running** - 8 frames
- **Slashing** (Attack) - 12 frames

### Also Available (Not Yet Copied)
- Dying, Falling Down, Hurt
- Jump Start, Jump Loop
- Kicking, Throwing
- Run Slashing, Run Throwing
- Sliding

## Setting Up in Godot

### Method 1: AnimatedSprite2D with Individual Frames (Recommended for Now)

1. **Open player.tscn in Godot**
2. **Select the AnimatedSprite2D node**
3. **In Inspector, click SpriteFrames resource**
4. **In SpriteFrames panel (bottom):**
   - Delete the old "default" animation
   - Click "New Animation" button
   - Name it "idle"
   - Click the film strip icon to add frames
   - Navigate to `res://assets/sprites/characters/necromancer_chibi/idle/`
   - Select all PNG files (Ctrl+A)
   - Click "Open"
   - Set FPS to 10

5. **Repeat for other animations:**
   - "walk" - 12 FPS
   - "run" - 10 FPS  
   - "attack" - 12 FPS

6. **Adjust sprite scale:**
   - These sprites are high-res (around 500x500px)
   - Set AnimatedSprite2D scale to `Vector2(0.1, 0.1)` or smaller
   - Adjust based on how it looks in game

### Method 2: Create Spritesheet (Advanced)

If individual frames are too many files, you can combine them into spritesheets using a tool like:
- TexturePacker
- Free Texture Packer
- Godot's built-in atlas system

## Next Steps

1. Open Godot and import the sprites (should auto-import)
2. Set up AnimatedSprite2D with the idle animation first
3. Test in game to see the character
4. Add walk/run animations
5. Update player.gd to switch animations based on movement

## Animation Switching Logic

```gdscript
func handle_movement():
    var input_direction = Vector2.ZERO
    
    if Input.is_action_pressed("ui_right"):
        input_direction.x += 1
    if Input.is_action_pressed("ui_left"):
        input_direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        input_direction.y += 1
    if Input.is_action_pressed("ui_up"):
        input_direction.y -= 1
    
    if input_direction.length() > 0:
        input_direction = input_direction.normalized()
        velocity = input_direction * move_speed
        animated_sprite.play("walk")  # or "run" if you want faster
    else:
        velocity = Vector2.ZERO
        animated_sprite.play("idle")
    
    move_and_slide()
```

## Other Necromancer Variants

You have 2 more variants available:
- Necromancer_of_the_Shadow_2
- Necromancer_of_the_Shadow_3

These can be used for:
- Different player character options
- Enemy necromancers
- Summoned units with different appearances

## Visual Differentiation for Summons

Once you have enemies/summons working, add this to summoned units:

```gdscript
# In summoned unit script
func _ready():
    # Add cyan/teal tint
    modulate = Color(0.5, 1.0, 1.0, 0.9)  # Cyan with slight transparency
```

Or create a shader for glow effect later.
