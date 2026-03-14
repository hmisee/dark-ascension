# Enemy Sprite Setup Guide

## Step 1: Download the Sprites

### Skeleton (Melee Enemy)
- URL: https://craftpix.net/freebies/chibi-skeleton-warrior-character-sprites/
- Click "Unlock Download" (free account required)
- Extract the ZIP

### Wraith (Ranged Enemy)
- URL: https://craftpix.net/freebies/free-wraith-tiny-style-2d-sprites/
- Click "Unlock Download" (free account required)
- Extract the ZIP

---

## Step 2: Copy Frames into Project

Inside each downloaded ZIP you'll find PNG folders per animation.
Copy them into the project like this:

```
assets/sprites/enemies/
├── skeleton/
│   ├── idle/     ← copy idle PNG frames here
│   ├── walk/     ← copy walking PNG frames here
│   ├── attack/   ← copy slashing PNG frames here
│   └── death/    ← copy dying PNG frames here
└── wraith/
    ├── idle/     ← copy idle PNG frames here
    ├── walk/     ← copy walking PNG frames here
    ├── attack/   ← copy attacking/casting PNG frames here
    └── death/    ← copy dying PNG frames here
```

---

## Step 3: Set Up Skeleton Animations in Godot

1. Open `scenes/skeleton_enemy.tscn`
2. Select the `AnimatedSprite2D` node
3. In the Inspector, click the `SpriteFrames` field → "New SpriteFrames"
4. The SpriteFrames panel opens at the bottom

For each animation:

### "idle" animation
- Click "Add Animation", name it `idle`
- Set Speed: 10 FPS, Loop: ON
- Click the film strip icon → navigate to `assets/sprites/enemies/skeleton/idle/`
- Select all PNGs → Open

### "walk" animation
- Click "Add Animation", name it `walk`
- Set Speed: 10 FPS, Loop: ON
- Add frames from `assets/sprites/enemies/skeleton/walk/`

### "attack" animation
- Click "Add Animation", name it `attack`
- Set Speed: 12 FPS, Loop: OFF
- Add frames from `assets/sprites/enemies/skeleton/attack/`

### "death" animation
- Click "Add Animation", name it `death`
- Set Speed: 10 FPS, Loop: OFF
- Add frames from `assets/sprites/enemies/skeleton/death/`

5. Adjust `AnimatedSprite2D` scale if needed (start with `Vector2(0.15, 0.15)`)
6. Save the scene

---

## Step 4: Set Up Wraith Animations in Godot

1. Open `scenes/ghost_enemy.tscn`
2. Select the `AnimatedSprite2D` node
3. In the Inspector, click `SpriteFrames` → "New SpriteFrames"

### "idle" animation
- Name: `idle`, Speed: 8 FPS, Loop: ON
- Add frames from `assets/sprites/enemies/wraith/idle/`

### "walk" animation
- Name: `walk`, Speed: 10 FPS, Loop: ON
- Add frames from `assets/sprites/enemies/wraith/walk/`

### "attack" animation
- Name: `attack`, Speed: 12 FPS, Loop: OFF
- Add frames from `assets/sprites/enemies/wraith/attack/`

### "death" animation
- Name: `death`, Speed: 10 FPS, Loop: OFF
- Add frames from `assets/sprites/enemies/wraith/death/`

4. Adjust scale if needed
5. Save the scene

---

## Step 5: Test in Game

Run `scenes/dungeon/arena_test.tscn` and verify:
- [ ] Skeleton plays idle when spawned
- [ ] Skeleton plays walk when chasing player
- [ ] Skeleton flashes red when hit
- [ ] Skeleton plays death animation when killed
- [ ] Wraith plays idle when at range
- [ ] Wraith plays walk when moving
- [ ] Wraith plays attack when shooting
- [ ] Wraith plays death animation when killed

---

## Troubleshooting

**Sprites appear too large/small**
- Adjust `scale` on the `AnimatedSprite2D` node
- The necromancer uses `Vector2(0.2, 0.2)` as reference

**Animation not playing**
- Check animation names match exactly: `idle`, `walk`, `attack`, `death`
- These are hardcoded in `scripts/entities/enemy.gd`

**Sprite facing wrong direction**
- The scripts assume sprites face RIGHT by default
- If your sprites face left, tick "Flip H" on the AnimatedSprite2D node as default

**Frames out of order**
- Godot imports alphabetically, so name frames `000`, `001`, `002`... for correct order
