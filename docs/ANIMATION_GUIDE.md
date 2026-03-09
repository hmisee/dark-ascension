# Animation Guide

## Current Status
✅ Necromancer idle sprite created: `assets/sprites/characters/necromancer_idle.png`

## Animation Frames Needed

For a basic playable prototype, you need:

### Priority 1 (Minimum Viable):
- **Idle** (1 frame) - ✅ DONE
- **Walk** (4 frames, 4 directions: down, up, left, right)

### Priority 2 (Polish):
- **Casting** (3-4 frames)
- **Hit/Damage** (1-2 frames)

### Priority 3 (Full animations):
- **Walk** (8 directions for smooth movement)
- **Death** animation

---

## Generating Walk Animations

### Approach 1: Generate Each Frame (Recommended for now)

Use the same Stable Diffusion prompt but add direction:

**Walking Down (towards camera):**
```
pixel art sprite, necromancer mage walking towards camera, 3/4 isometric view, 
purple and black tattered robes, deep dark hood covering face, faceless, 
holding wooden staff, dark fantasy, walking animation frame,
clean pixel art, transparent background, game character sprite, 
single character, full body, simple design
```

**Walking Up (away from camera):**
```
pixel art sprite, necromancer mage walking away, back view, 3/4 isometric view, 
purple and black tattered robes, deep dark hood, faceless, 
holding wooden staff, dark fantasy, walking animation frame,
clean pixel art, transparent background, game character sprite, 
single character, full body, simple design
```

**Walking Left/Right:**
```
pixel art sprite, necromancer mage walking sideways, side view, 3/4 isometric view, 
purple and black tattered robes, deep dark hood, faceless, 
holding wooden staff, dark fantasy, walking animation frame,
clean pixel art, transparent background, game character sprite, 
single character, full body, simple design
```

Generate 2-4 variations of each direction, then process with the script.

### Approach 2: Manual Pixel Art (Faster for simple animations)

Since you have the idle sprite, you can:
1. Open `necromancer_idle.png` in a pixel art editor (Aseprite, Piskel, or Photopea)
2. Manually adjust limbs for walk cycle
3. Much faster than AI generation for small sprites

---

## Processing Multiple Sprites

Use the batch processing script:

```bash
python tools/process_sprite.py
```

Or process individually by editing the script's input/output paths.

---

## Godot Animation Setup

Once you have frames, Godot's AnimatedSprite2D node handles the rest:

1. Import all frames to `assets/sprites/characters/`
2. Create AnimatedSprite2D in character scene
3. Add animations (idle, walk_down, walk_up, walk_left, walk_right)
4. Set FPS (usually 8-12 for pixel art)
5. Script controls which animation plays

---

## Quick Start Recommendation

For fastest prototype:
1. Use the single idle frame for now
2. Build the movement and gameplay first
3. Add walk animations later once gameplay feels good

The idle sprite will slide around, but you can test all the core mechanics without animations.

Want to proceed with gameplay implementation or generate walk frames first?
