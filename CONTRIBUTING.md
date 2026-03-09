# Contributing to Dark Ascension

## Git Workflow

### Branch Strategy

- `main` - Stable, playable builds only
- `develop` - Active development branch
- `feature/*` - New features (e.g., `feature/shadow-system`)
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks
- `asset`: New or updated game assets

**Examples:**
```
feat(combat): add formation toggle system
fix(shadows): resolve positioning bug on level load
docs(readme): update installation instructions
asset(sprites): add necromancer idle animation
```

### Making Changes

1. Create a new branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

3. Push to GitHub:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request to `develop` branch

## Code Standards

### GDScript Style Guide

- Use snake_case for variables and functions
- Use PascalCase for class names
- Use UPPER_CASE for constants
- Indent with tabs (Godot default)
- Add comments for complex logic

### File Organization

```
res://
├── scenes/          # Game scenes
├── scripts/         # GDScript files
├── assets/          # Game assets
│   ├── sprites/     # Character and object sprites
│   ├── audio/       # Music and sound effects
│   └── fonts/       # UI fonts
├── resources/       # Godot resources (.tres files)
└── addons/          # Third-party plugins
```

## Asset Guidelines

### Sprites
- Format: PNG with transparency
- Naming: `entity_action_frame.png` (e.g., `necromancer_idle_01.png`)
- Size: 32x32 or 64x64 pixels (consistent per entity type)

### Audio
- Music: OGG format, loopable
- SFX: WAV format, short duration
- Naming: descriptive (e.g., `sword_swing.wav`, `boss_theme.ogg`)

## Testing

Before submitting:
1. Test your changes in Godot
2. Ensure no console errors
3. Check that existing features still work
4. Update documentation if needed

## Questions?

Open an issue or discussion on GitHub!
