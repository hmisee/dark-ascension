# Requirements Document

## Introduction

The Game Options System provides players with configurable display and input settings for Dark Ascension. The system covers display mode selection (fullscreen, borderless window, windowed), resolution changes, WASD key rebinding, and persistent save/load of all settings. The game launches in fullscreen by default and restores saved settings on startup.

## Glossary

- **Options_Manager**: The autoload singleton responsible for storing, applying, saving, and loading all game settings.
- **Options_Menu**: The UI screen where the player views and modifies display and input settings.
- **Display_Mode**: One of three window modes: Fullscreen, Borderless Window, or Windowed.
- **Resolution**: The viewport width and height in pixels (e.g., 1920x1080, 1280x720).
- **Key_Binding**: The mapping between a game action (move_up, move_down, move_left, move_right) and a keyboard key.
- **Settings_File**: A configuration file stored on disk that persists player settings between game sessions.
- **Main_Menu**: The title screen with navigation buttons including the Options button.

## Requirements

### Requirement 1: Fullscreen by Default

**User Story:** As a player, I want the game to launch in fullscreen mode by default, so that I get an immersive experience without manual configuration.

#### Acceptance Criteria

1. THE Options_Manager SHALL set the Display_Mode to Fullscreen when no Settings_File exists.
2. WHEN the game starts and a Settings_File exists, THE Options_Manager SHALL apply the Display_Mode stored in the Settings_File.

### Requirement 2: Display Mode Selection

**User Story:** As a player, I want to switch between fullscreen, borderless window, and windowed modes, so that I can choose the display style that suits my setup.

#### Acceptance Criteria

1. THE Options_Menu SHALL present three Display_Mode choices: Fullscreen, Borderless Window, and Windowed.
2. WHEN the player selects a Display_Mode in the Options_Menu, THE Options_Manager SHALL apply the selected Display_Mode to the game window immediately.
3. WHEN the player selects Fullscreen, THE Options_Manager SHALL set the window mode to exclusive fullscreen.
4. WHEN the player selects Borderless Window, THE Options_Manager SHALL set the window to borderless fullscreen.
5. WHEN the player selects Windowed, THE Options_Manager SHALL set the window to a resizable bordered window at the selected Resolution.

### Requirement 3: Resolution Selection

**User Story:** As a player, I want to change the game resolution, so that I can match my monitor or adjust performance.

#### Acceptance Criteria

1. THE Options_Menu SHALL present a list of supported resolutions: 1920x1080, 1600x900, 1280x720, and 1024x576.
2. WHEN the player selects a Resolution in the Options_Menu, THE Options_Manager SHALL apply the selected Resolution to the game viewport.
3. WHILE the Display_Mode is Windowed, THE Options_Manager SHALL resize the game window to match the selected Resolution.
4. THE Options_Manager SHALL default to 1920x1080 Resolution when no Settings_File exists.

### Requirement 4: WASD Key Rebinding

**User Story:** As a player, I want to rebind the WASD movement keys, so that I can use a key layout that is comfortable for me.

#### Acceptance Criteria

1. THE Options_Menu SHALL display the current Key_Binding for each movement action: move_up, move_down, move_left, and move_right.
2. WHEN the player activates a rebind button for a movement action, THE Options_Menu SHALL enter a listening state and display a prompt indicating it is waiting for a key press.
3. WHEN the player presses a key during the listening state, THE Options_Manager SHALL assign the pressed key to the selected movement action.
4. IF the player presses a key that is already bound to a different movement action, THEN THE Options_Manager SHALL swap the Key_Bindings between the two actions.
5. WHEN a Key_Binding changes, THE Options_Manager SHALL update the Godot InputMap for the affected action immediately.
6. THE Options_Manager SHALL preserve non-WASD key events (such as arrow key alternatives) when rebinding a movement action.

### Requirement 5: Settings Persistence

**User Story:** As a player, I want my settings to be saved and loaded automatically, so that I do not have to reconfigure options every time I start the game.

#### Acceptance Criteria

1. WHEN the player confirms changes in the Options_Menu, THE Options_Manager SHALL write all current settings to the Settings_File.
2. THE Options_Manager SHALL store the Settings_File at the path "user://settings.cfg".
3. WHEN the game starts, THE Options_Manager SHALL load settings from the Settings_File and apply them before the first scene is displayed.
4. IF the Settings_File is missing or corrupted, THEN THE Options_Manager SHALL apply default settings (Fullscreen mode, 1920x1080 resolution, standard WASD bindings).
5. THE Options_Manager SHALL serialize settings using Godot ConfigFile format.
6. FOR ALL valid settings states, saving then loading the Settings_File SHALL produce an equivalent settings state (round-trip property).

### Requirement 6: Options Menu Navigation

**User Story:** As a player, I want to open and close the options menu easily, so that I can adjust settings without disrupting gameplay flow.

#### Acceptance Criteria

1. WHEN the player presses the Options button on the Main_Menu, THE Main_Menu SHALL open the Options_Menu.
2. THE Options_Menu SHALL include an Apply button that saves settings and returns to the Main_Menu.
3. THE Options_Menu SHALL include a Cancel button that discards unsaved changes and returns to the Main_Menu.
4. WHEN the player presses Cancel, THE Options_Manager SHALL revert all settings to the values from before the Options_Menu was opened.
