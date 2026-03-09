# Asset Generation Guide

## Character Design Decisions

### Main Character: The Necromancer
- **Style**: Pixel art (64x64 starting resolution)
- **Archetype**: Desperate mage
- **Color Palette**: Purple and black robes (teal/cyan reserved for spell effects)
- **Perspective**: 3/4 view (isometric-style)

---

## Stable Diffusion Prompts

### Necromancer Character Sprite

**Recommended Settings:**
- Model: Stable Diffusion v1.5 or pixel art specific model
- Steps: 30-50
- CFG Scale: 7-9
- Sampler: Euler a or DPM++ 2M
- Size: 512x512 (will downscale to 64x64)

**Prompt (Hooded - No Face Visible):**
```
pixel art sprite, necromancer mage, 3/4 isometric view, 
purple and black tattered robes, deep dark hood covering face, faceless, 
holding wooden staff, dark fantasy, 
clean pixel art, transparent background, game character sprite, 
single character, full body, simple design
```

**Negative Prompt:**
```
face visible, facial features, eyes, mouth, smile, happy, 
blurry, realistic, 3d render, photograph, multiple characters, 
cyan, teal, bright colors, cheerful, glowing effects,
messy, low quality, watermark, text, armor
```

**Tips:**
- Generate multiple variations (4-8 images)
- Hooded/faceless design works better at small pixel sizes
- Look for clean silhouettes that read well when small
- Purple/black should be dominant colors
- Mysterious hooded figure adds to the dark atmosphere
- Save teal/cyan for spell VFX later (shadow summoning effects)
- If face still appears, add "no face, shadowed face" to prompt

---

## Post-Processing

### After Generation:

1. **Select best image** from batch
2. **Crop and center** character in image editor
3. **Downscale** to 64x64 pixels using nearest-neighbor (to preserve pixel art look)
4. **Remove background** if not transparent
5. **Adjust colors** if needed (boost teal accents)
6. **Save as PNG** to `assets/sprites/characters/necromancer_idle.png`

### Animation Frames (Future):

Once you have the base sprite, generate variations for:
- Idle animation (2-4 frames)
- Walking (4-8 frames, 8 directions)
- Casting spell (3-5 frames)
- Taking damage (1-2 frames)

---

## Shadow Sprites (Next Priority)

After necromancer is done, generate shadows with similar style:

### Shadow Types to Create:
1. **Skeleton Warrior** (Tank/Fighter)
2. **Shadow Archer** (Ranged)
3. **Wraith** (Support/Fighter)

Use same prompt structure but replace character description.

---

## Enemy Sprites

Generate after shadows are complete. Keep consistent style and perspective.

---

## Item Sprites

Small 16x16 or 32x32 icons for backpack system.

---

## Notes

- Always keep original high-res generations as backup
- Maintain consistent lighting direction (top-left)
- Test sprites in-game at actual size before finalizing
- Document any prompt variations that work well
