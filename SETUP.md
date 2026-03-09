# Development Environment Setup

This guide will help you set up everything needed to develop Dark Ascension.

## Prerequisites

- Windows 10/11
- 8GB+ RAM (16GB recommended)
- NVIDIA GPU with 4GB+ VRAM (for AI asset generation)

## Required Software

### 1. Godot 4

**Download**: https://godotengine.org/download

1. Download Godot 4 (latest stable version)
2. Extract to a convenient location (e.g., `C:\Godot`)
3. No installation needed - just run `Godot_v4.x.exe`

### 2. Stable Diffusion WebUI Forge

**Location**: `C:\StableDiffusion\stable-diffusion-webui-forge`

Already installed and configured with:
- Python 3.12.10
- PyTorch 2.3.1 with CUDA 12.1
- Stable Diffusion v1.5 model

**To start Stable Diffusion:**
```powershell
cd C:\StableDiffusion\stable-diffusion-webui-forge
.\webui-user.bat
```

Then open: http://127.0.0.1:7860

### 3. Git (Optional but recommended)

**Download**: https://git-scm.com/download/win

For version control and collaboration.

## Project Setup

### Clone/Download Project

```powershell
# If using Git
git clone <repository-url>
cd dark-ascension

# Or download and extract ZIP
```

### Open in Godot

1. Launch Godot 4
2. Click "Import"
3. Navigate to project folder
4. Select `project.godot`
5. Click "Import & Edit"

## Asset Generation Workflow

### Generating Sprites

1. Start Stable Diffusion (see above)
2. Use prompts from `docs/ASSET_GENERATION.md`
3. Save generated images to `assets/sprites/`
4. Import into Godot (automatic on save)

### Audio Assets

- **Music**: Use Suno (https://suno.ai) - free tier available
- **SFX**: Use Freesound.org or generate with AI tools
- Save to `assets/audio/`

## Troubleshooting

### Stable Diffusion Issues

**NumPy warnings**: Safe to ignore, doesn't affect functionality

**"No module named 'joblib'"**: Optional module, doesn't affect core functionality

**GPU not detected**: Ensure NVIDIA drivers are up to date

### Godot Issues

**Project won't open**: Ensure you're using Godot 4.x (not 3.x)

**Assets not showing**: Check that files are in correct folders under `res://`

## Development Tools

### Recommended VS Code Extensions (if using external editor)

- godot-tools
- GDScript syntax highlighting

### Useful Resources

- Godot Documentation: https://docs.godotengine.org/
- GDScript Reference: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- Stable Diffusion Prompting Guide: https://stable-diffusion-art.com/prompt-guide/

## Next Steps

Once setup is complete:
1. Read [GAME_DESIGN.md](docs/GAME_DESIGN.md) for game mechanics
2. Check [ASSET_GENERATION.md](docs/ASSET_GENERATION.md) for sprite generation
3. Start with the prototype milestone in project board

## Support

For issues or questions, check the project documentation or create an issue in the repository.
