# TODO - Next Session: Enemy Sprites & Shadow System

## Session Goals
Implement proper enemy sprites and create a shadow companion system with visual distinction.

---

## Part 1: Enemy Sprite Integration

### 1.1 Find/Acquire Enemy Sprites
**Goal**: Get sprite sheets for Skeleton and Ghost enemies

**Options**:
- [ ] Search CraftPix for matching chibi-style enemies
- [ ] Check itch.io for free/paid sprite packs
- [ ] Look for OpenGameArt.org resources
- [ ] Consider AI-generated sprites if needed

**Requirements**:
- Must match necromancer's chibi art style
- Need idle and walk animations minimum
- Attack animation optional but nice
- Death animation optional but nice
- Prefer 900x900 or similar size (to match necromancer)

**Recommended Search Terms**:
- "chibi skeleton sprite"
- "chibi ghost sprite"
- "cute undead sprites"
- "pixel art skeleton animated"

### 1.2 Import Enemy Sprites
**Location**: `assets/sprites/enemies/`

**Structure**:
```
assets/sprites/enemies/
├── skeleton/
│   ├── idle/
│   ├── walk/
│   ├── attack/ (optional)
│   └── death/ (optional)
└── ghost/
    ├── idle/
    ├── walk/
    ├── attack/ (optional)
    └── death/ (optional)
```

**Tasks**:
- [ ] Create folder structure
- [ ] Import skeleton sprite sheets
- [ ] Import ghost sprite sheets
- [ ] Verify import settings in Godot (2D Pixel, no filter)

### 1.3 Update Enemy Scenes
**Files to modify**:
- `scenes/skeleton_enemy.tscn`
- `scenes/ghost_enemy.tscn`

**Tasks**:
- [ ] Replace Polygon2D nodes with AnimatedSprite2D
- [ ] Create SpriteFrames resources
- [ ] Add idle animation
- [ ] Add walk animation
- [ ] Set appropriate scale (likely 0.1-0.2 like player)
- [ ] Test animations in game
- [ ] Adjust collision shapes if needed

---

## Part 2: Shadow Companion System

### 2.1 Design Decisions to Make

**Visual Distinction**:
- [ ] Decide on teal overlay method:
  - Option A: Modulate color (simple, changes entire sprite)
  - Option B: Shader with teal glow/outline
  - Option C: Duplicate sprites with teal tint
  - **Recommended**: Start with modulate, upgrade to shader later

**Formation System**:
- [ ] Melee shadow: Position in front of player
- [ ] Ranged shadow: Position behind player
- [ ] Offset distance: ~50-80 pixels?
- [ ] Follow behavior: Smooth lerp or direct follow?

**Direction Handling**:
- [ ] Option A: Shadows face same direction as player (simple)
- [ ] Option B: Shadows face nearest enemy (more complex)
- [ ] Option C: Shadows face movement direction (medium)
- [ ] **Recommended**: Start with Option A, iterate later

### 2.2 Create Shadow Base Class
**New file**: `scripts/entities/shadow.gd`

**Features to implement**:
- [ ] Extends CharacterBody2D
- [ ] Reference to player
- [ ] Formation position (front/back)
- [ ] Follow player with offset
- [ ] Teal visual effect (modulate or shader)
- [ ] Health system (inherited from enemies?)
- [ ] Attack behavior (auto-attack like player)
- [ ] Collision with enemies

**Key properties**:
```gdscript
@export var formation_offset: Vector2  # Relative to player
@export var follow_speed: float = 150.0
@export var teal_tint: Color = Color(0, 0.8, 0.8, 1)
var player: Node2D
var shadow_type: String  # "melee" or "ranged"
```

### 2.3 Create Shadow Variants
**New files**:
- `scripts/entities/shadow_skeleton.gd` (melee)
- `scripts/entities/shadow_ghost.gd` (ranged)

**Tasks**:
- [ ] Extend shadow base class
- [ ] Set formation_offset (front for melee, back for ranged)
- [ ] Implement attack behavior
- [ ] Use same sprites as enemies but with teal tint
- [ ] Test movement and following

### 2.4 Create Shadow Scenes
**New files**:
- `scenes/shadow_skeleton.tscn`
- `scenes/shadow_ghost.tscn`

**Tasks**:
- [ ] Copy enemy scene structure
- [ ] Apply teal modulate to AnimatedSprite2D
- [ ] Attach shadow scripts
- [ ] Set collision layers (different from enemies)
- [ ] Add to "shadow" group
- [ ] Test in arena

### 2.5 Integrate with Player
**File to modify**: `scripts/entities/player.gd`

**Tasks**:
- [ ] Add shadow spawning system
- [ ] Track active shadows (array)
- [ ] Update shadow positions each frame
- [ ] Pass player reference to shadows
- [ ] Handle shadow death/respawn

**Pseudo-code**:
```gdscript
var shadows: Array[Shadow] = []

func spawn_shadow(shadow_scene: PackedScene):
    var shadow = shadow_scene.instantiate()
    shadow.player = self
    get_parent().add_child(shadow)
    shadows.append(shadow)

func _physics_process(delta):
    # Existing code...
    update_shadow_positions()

func update_shadow_positions():
    for shadow in shadows:
        shadow.target_position = global_position + shadow.formation_offset
```

### 2.6 Formation System
**Considerations**:
- [ ] Melee shadow offset: Vector2(-60, 0) or based on facing?
- [ ] Ranged shadow offset: Vector2(60, 0) or based on facing?
- [ ] Should shadows rotate around player when facing changes?
- [ ] Smooth interpolation vs instant positioning?

**Implementation options**:
```gdscript
# Option A: Fixed relative position
formation_offset = Vector2(-60, 0)  # Always left

# Option B: Based on player facing
if player.animated_sprite.flip_h:
    formation_offset = Vector2(60, 0)  # Behind when facing left
else:
    formation_offset = Vector2(-60, 0)  # In front when facing right

# Option C: Based on cursor direction
var cursor_dir = (cursor_pos - player.pos).normalized()
formation_offset = cursor_dir * -60  # Behind player relative to cursor
```

---

## Part 3: Testing & Polish

### 3.1 Test Scenarios
- [ ] Spawn one melee shadow
- [ ] Spawn one ranged shadow
- [ ] Spawn both shadows together
- [ ] Test shadow following at different speeds
- [ ] Test shadow attacks on enemies
- [ ] Test shadows taking damage
- [ ] Test shadow death and respawn
- [ ] Test formation with player movement
- [ ] Test formation with direction changes

### 3.2 Visual Polish
- [ ] Adjust teal tint intensity
- [ ] Add glow effect to shadows (optional)
- [ ] Add shadow spawn animation (optional)
- [ ] Add shadow death animation (optional)
- [ ] Ensure shadows are visually distinct from enemies

### 3.3 Balance Adjustments
- [ ] Shadow health values
- [ ] Shadow damage values
- [ ] Shadow attack speed
- [ ] Formation distances
- [ ] Follow speed

---

## Part 4: Documentation

### 4.1 Create Documentation
**New file**: `docs/SHADOW_SYSTEM.md`

**Content**:
- [ ] Shadow system overview
- [ ] How to spawn shadows
- [ ] Formation system explanation
- [ ] Visual distinction (teal effect)
- [ ] Shadow types and behaviors
- [ ] Customization options

### 4.2 Update Existing Docs
- [ ] Update `docs/PROJECT_STATUS.md`
- [ ] Update `docs/GAME_DESIGN.md` if needed
- [ ] Add shadow system to feature list

---

## Quick Reference: File Locations

### New Files to Create
```
scripts/entities/
├── shadow.gd (base class)
├── shadow_skeleton.gd
└── shadow_ghost.gd

scenes/
├── shadow_skeleton.tscn
└── shadow_ghost.tscn

docs/
└── SHADOW_SYSTEM.md
```

### Files to Modify
```
scripts/entities/player.gd (add shadow management)
scenes/skeleton_enemy.tscn (replace with sprites)
scenes/ghost_enemy.tscn (replace with sprites)
docs/PROJECT_STATUS.md (update features)
```

---

## Open Questions to Decide

1. **Shadow Spawning**: 
   - Manual spawn for testing?
   - Auto-spawn at game start?
   - Unlock system later?

2. **Shadow Limits**:
   - Start with 2 shadows (1 melee, 1 ranged)?
   - Allow more later?

3. **Shadow AI**:
   - Attack nearest enemy?
   - Attack player's target?
   - Independent targeting?

4. **Formation Rotation**:
   - Shadows stay in fixed positions?
   - Rotate around player based on facing?
   - Dynamic positioning based on enemies?

5. **Collision**:
   - Can shadows block enemies?
   - Can shadows block player?
   - Pass-through or solid?

---

## Success Criteria

By end of next session, you should have:
- ✅ Proper sprites for Skeleton and Ghost enemies
- ✅ Animated enemies (idle/walk minimum)
- ✅ Shadow system with 2 shadow types
- ✅ Teal visual distinction for shadows
- ✅ Shadows following player in formation
- ✅ Shadows attacking enemies
- ✅ Basic formation system (melee front, ranged back)

---

## Notes

- Start with simple modulate for teal effect, can upgrade to shader later
- Formation can be simple fixed positions first, make dynamic later
- Focus on getting it working, polish can come after
- Test frequently as you build each piece
- Don't worry about perfect sprite matching - placeholder is fine to start

---

**Estimated Time**: 2-3 hours
**Priority**: High (core gameplay feature)
**Difficulty**: Medium (new system but building on existing code)

Good luck! 🎮✨
