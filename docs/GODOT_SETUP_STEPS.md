# Step-by-Step: Setting Up Necromancer Sprites in Godot

## Prerequisites
✅ Sprites copied to `assets/sprites/characters/necromancer_chibi/`
✅ Godot project open

## Step 1: Wait for Import (30 seconds)
When you switch to Godot, it will automatically import all the PNG files. Wait for the import to finish (check bottom-right progress bar).

## Step 2: Open Player Scene
1. In FileSystem panel (bottom-left), navigate to `res://scenes/`
2. Double-click `player.tscn`

## Step 3: Select AnimatedSprite2D Node
1. In Scene panel (top-left), click on `AnimatedSprite2D` node
2. Look at Inspector panel (right side)

## Step 4: Open SpriteFrames Editor
1. In Inspector, find "Sprite Frames" property
2. Click on the SpriteFrames resource (should show a preview)
3. This opens the SpriteFrames panel at the bottom of the screen

## Step 5: Create Idle Animation
1. In SpriteFrames panel, you'll see "default" animation
2. Click the "Rename Animation" button (pencil icon) and rename to "idle"
3. Click the "Add frames from sprite sheet" button (film strip icon with +)
4. Navigate to `res://assets/sprites/characters/necromancer_chibi/idle/`
5. Select the FIRST PNG file (000)
6. Click "Open"
7. In the dialog that appears:
   - It will ask about frames - just click "Add X Frame(s)"
8. Repeat steps 3-7 for each idle frame (000 through 009)
   - OR select all files at once (Ctrl+A) and add them together

## Step 6: Set Animation Speed
1. With "idle" animation selected
2. Find "Speed (FPS)" setting in SpriteFrames panel
3. Set it to `10`

## Step 7: Adjust Sprite Scale
1. Select AnimatedSprite2D node in Scene panel
2. In Inspector, find "Transform > Scale"
3. Change from `(0.3, 0.3)` to `(0.1, 0.1)`
4. If character is still too big/small, adjust this value

## Step 8: Test the Animation
1. Click the "Play" button at top (or press F5)
2. You should see the necromancer idle animation!

## Step 9: Add Walk Animation (Optional)
1. In SpriteFrames panel, click "New Animation" button
2. Name it "walk"
3. Repeat Step 5 but use files from `necromancer_chibi/walk/` folder
4. Set FPS to `12`

## Step 10: Update Player Script (Optional)
If you added walk animation, update `scripts/entities/player.gd`:

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
        animated_sprite.play("walk")  # Play walk animation
    else:
        velocity = Vector2.ZERO
        animated_sprite.play("idle")  # Play idle animation
    
    move_and_slide()
```

## Troubleshooting

### Character is too big
- Decrease Scale values (try 0.05, 0.05)

### Character is too small  
- Increase Scale values (try 0.15, 0.15)

### Animation not playing
- Make sure animation name in code matches SpriteFrames ("idle", not "Idle")
- Check that FPS is not 0

### Sprites not showing
- Wait for import to complete
- Check FileSystem panel - sprites should have preview icons
- Right-click sprite > Reimport if needed

## What You Should See

After Step 8, you should see:
- A purple/dark robed necromancer character
- Idle breathing animation (subtle movement)
- Character responds to WASD/Arrow keys (if walk animation added)

## Next Steps

Once this works:
1. Add run animation (faster movement)
2. Add attack animation (for combat)
3. Try the other 2 necromancer variants
4. Start thinking about enemy sprites
