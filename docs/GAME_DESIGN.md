# Dark Ascension - Game Design Document

## High-Level Concept

A 2D turn-based auto-battler dungeon crawler combining Vampire Survivors' addictive run-based gameplay, Solo Leveling's shadow extraction fantasy, and Backpack Battles' strategic inventory management.

## Core Pillars

1. **Discovery Over Optimization** - No wikis, experimentation rewarded
2. **Meaningful Choices** - Shadow selection and item positioning matter
3. **Addictive Loop** - "One more run" syndrome
4. **Strategic Depth** - Simple to learn, deep to master

---

## Game Loop

### Pre-Dungeon Phase
1. Select 3-4 shadows from collection
2. Assign roles (Tank/Fighter/Support/Ranged)
3. Arrange items in backpack grid
4. Enter dungeon floor

### Dungeon Run Phase (Vampire Survivors style)
1. Top-down 2D arena
2. Necromancer moves freely (WASD/click)
3. Shadows follow in formation
4. Waves of enemies spawn
5. Auto-combat with cooldown-based abilities
6. Items drop during run
7. Survive waves or defeat boss

### Post-Run Phase
1. Extract shadows from defeated elites/bosses
2. Organize collected items in backpack
3. Unlock new dungeon floors
4. Meta progression unlocks

---

## Core Systems

### 1. Shadow System

**Shadow Acquisition**
- Extract from defeated boss/elite enemies
- Each shadow has unique abilities and stats
- Limited slots (start with 2-3, unlock up to 6+)

**Shadow Roles**
- **Tank**: High HP, draws aggro, frontline
- **Fighter**: Balanced damage/defense, mid-front
- **Ranged**: High damage, low defense, backline  
- **Support**: Buffs/heals, mid-back

**Shadow Customization**
- Assign role before dungeon (some shadows better at certain roles)
- Shadows level up through use
- Unlock shadow-specific abilities

**Example Shadows**
- Skeleton Warrior (Tank/Fighter)
- Shadow Archer (Ranged)
- Wraith (Support/Fighter)
- Bone Mage (Ranged/Support)

### 2. Formation & Combat System

**Auto-Positioning**
- Shadows automatically position based on assigned role
- Tank → front
- Fighter → mid-front
- Ranged → back
- Support → mid-back

**Formation Modes** (Toggle with F key)
- **Aggressive**: Spread out, +damage, -defense
- **Defensive**: Tight formation, +defense, -damage

**Facing Direction**
- Facing enemies = damage bonus
- Flanked/surrounded = damage reduction penalty
- Necromancer movement controls team positioning

**Combat Flow**
- Auto-attacks based on shadow abilities
- Cooldown-based special abilities
- No manual targeting (closest valid target)
- Kiting and positioning is the skill expression

### 3. Backpack System

**Grid-Based Inventory**
- Start: 4x4 grid
- Expandable through progression
- Items only affect necromancer (not shadows)

**Item Types**
- Weapons (damage, attack speed)
- Armor (defense, HP)
- Accessories (special effects)
- Consumables (temporary buffs)

**Adjacency Bonuses**
- Items placed next to each other create synergies
- Example: Sword + Shield = block chance
- Example: Staff + Tome = spell power
- Hidden synergies to discover

**Item Management**
- Organize between runs
- Items found during runs
- Tetris-like positioning puzzle

### 4. Dungeon Progression

**Floor Structure**
- 10 floors initially (expandable)
- Each floor: 3-5 waves + boss
- Increasing difficulty
- Unique enemy types per floor

**Enemy Design**
- Regular mobs (cannon fodder)
- Elites (mini-bosses, can extract shadows)
- Bosses (guaranteed shadow extraction)

**Environmental Storytelling**
- Each floor has visual theme
- Lore snippets from shadow descriptions
- Mystery: Why are you here? What happened?

### 5. Meta Progression

**Permanent Unlocks**
- New shadow slots
- Backpack expansions
- Starting item options
- New dungeon floors

**Discovery Journal**
- Tracks discovered item synergies
- Shadow role effectiveness
- Enemy weaknesses
- No explicit tooltips, learn through play

**Challenges & Leaderboards**
- Daily/Weekly challenges
- Endless mode (how many waves?)
- Speedrun categories
- Restrictions (2 shadows only, no items, etc.)

---

## Progression Curve

### Early Game (Floors 1-3)
- Learn basic mechanics
- Collect first 3-4 shadows
- Discover basic item synergies
- Simple enemy patterns

### Mid Game (Floors 4-7)
- Build specialized teams
- Complex item combinations
- Tougher enemies require strategy
- Unlock meta progression

### Late Game (Floors 8-10)
- Optimize builds
- Master formation switching
- Challenge modes unlock
- Leaderboard competition

### End Game
- Endless mode
- Perfect runs
- All shadows collected
- Community theorycrafting

---

## Monetization (Future Consideration)

**Free-to-Play Model** (if applicable)
- Base game free
- Cosmetic skins (shadows, necromancer)
- No pay-to-win
- Optional battle pass

**Premium Model**
- One-time purchase
- All content included
- Cosmetic DLC optional

---

## Technical Specifications

### Minimum Viable Product (MVP)

**Scope for v1.0:**
- 10 dungeon floors
- 15-20 shadows
- 30-40 items
- Basic meta progression
- Daily challenges + leaderboards

**Art Style:**
- 2D pixel art or AI-generated sprites
- Dark fantasy aesthetic
- 32x32 or 64x64 sprites

**Performance Targets:**
- 60 FPS on mid-range hardware
- Fast load times (<5 seconds)
- Smooth auto-combat

### Post-Launch Content

- More shadows (20+ total)
- More items (50+ total)
- New dungeon floors
- Seasonal events
- Co-op raids (async multiplayer)
- PvP arena (turn-based)

---

## Design Principles

1. **Respect Player Time** - Runs are 10-15 minutes
2. **Reward Experimentation** - No "wrong" builds
3. **Clear Feedback** - Visual/audio cues for everything
4. **Accessibility** - Colorblind modes, remappable controls
5. **No FOMO** - Challenges rotate but rewards return

---

## Open Questions

- Exact shadow count for balance?
- Item rarity tiers or all equal?
- Permadeath or just run failure?
- Story delivery method?
- Multiplayer priority?

---

## References & Inspiration

- **Vampire Survivors**: Run structure, addictive loop
- **Backpack Battles**: Inventory positioning
- **Solo Leveling**: Shadow extraction fantasy
- **TFT/Auto Chess**: Auto-battler positioning
- **Slay the Spire**: Meta progression, discovery

---

*This is a living document. Update as design evolves.*
